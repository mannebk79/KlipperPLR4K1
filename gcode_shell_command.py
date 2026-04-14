# Run a shell command via gcode
# Optimized for Creality K1 Series / BusyBox
#
# Copyright (C) 2019  Eric Callahan <arksine.code@gmail.com>

import os
import shlex
import subprocess
import logging

class ShellCommand:
    def __init__(self, config):
        self.name = config.get_name().split()[-1]
        self.printer = config.get_printer()
        self.gcode = self.printer.lookup_object('gcode')
        cmd = config.get('command')
        # Auf dem K1C als root ist expanduser wichtig, falls Scripte in ~/ liegen
        cmd = os.path.expanduser(cmd)
        self.command = shlex.split(cmd)
        self.timeout = config.getfloat('timeout', 2., above=0.)
        self.verbose = config.getboolean('verbose', True)
        self.proc_fd = None
        self.partial_output = ""
        self.gcode.register_mux_command(
            "RUN_SHELL_COMMAND", "CMD", self.name,
            self.cmd_RUN_SHELL_COMMAND,
            desc=self.cmd_RUN_SHELL_COMMAND_help)

    def _process_output(self, eventime):
        if self.proc_fd is None:
            return
        try:
            # Nutze os.read fuer BusyBox Kompatibilitaet
            data = os.read(self.proc_fd, 4096)
        except Exception:
            return
        
        if not data:
            return

        data = self.partial_output + data.decode()
        if '\n' not in data:
            self.partial_output = data
            return
        elif data[-1] != '\n':
            split = data.rfind('\n') + 1
            self.partial_output = data[split:]
            data = data[:split]
        else:
            self.partial_output = ""
        self.gcode.respond_info(data)

    cmd_RUN_SHELL_COMMAND_help = "Run a linux shell command"
    def cmd_RUN_SHELL_COMMAND(self, params):
        gcode_params = params.get('PARAMS','')
        # shlex.split hilft hier enorm bei Pfaden mit Leerzeichen (S19/...)
        gcode_params = shlex.split(gcode_params)
        reactor = self.printer.get_reactor()
        try:
            proc = subprocess.Popen(
                self.command + gcode_params, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        except Exception:
            logging.exception(
                "shell_command: Command {%s} failed" % (self.name))
            raise self.gcode.error("Error running command {%s}" % (self.name))
        
        hdl = None
        if self.verbose:
            self.proc_fd = proc.stdout.fileno()
            self.gcode.respond_info("Running Command {%s}...:" % (self.name))
            hdl = reactor.register_fd(self.proc_fd, self._process_output)
        
        eventtime = reactor.monotonic()
        endtime = eventtime + self.timeout
        complete = False
        while eventtime < endtime:
            eventtime = reactor.pause(eventtime + .05)
            if proc.poll() is not None:
                complete = True
                break
        
        if not complete:
            proc.terminate()
        
        if self.verbose:
            if self.partial_output:
                self.gcode.respond_info(self.partial_output)
                self.partial_output = ""
            if complete:
                msg = "Command {%s} finished\n" % (self.name)
            else:
                msg = "Command {%s} timed out" % (self.name)
            self.gcode.respond_info(msg)
            if hdl:
                reactor.unregister_fd(hdl)
            self.proc_fd = None


def load_config_prefix(config):
    return ShellCommand(config)
