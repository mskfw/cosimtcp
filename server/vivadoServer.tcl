

proc cosimtcpServer {port} {
    proc_init_data
    puts "Starting ModelSim Server at $port port"
    set s [socket -server ServerAccept $port]
    vwait forever
}


proc ServerAccept {sock addr port} {
    # global echo

    # Record the client's information
    puts "Accept $sock from $addr port $port"
    # set echo(addr,$sock) [list $addr $ port]

    # FCONFIGURE
    # auto flush buffer  when  new line comes
    # translate new line to \n character
    fconfigure $sock -buffering line -translation lf

    catch {fileevent $sock readable [list VivadoReadSock $sock]} result
}

proc VivadoReadSock {sock} {

    global input
    global output

    global currentData
    global currentFunction

    if { [eof $sock] } {
        puts "End of sock $sock. Closing..."
        close $sock
        return
    } elseif { [catch {gets $sock line}]} {
        # end of file or abnormal connection drop
        puts "Error reading sock $sock. Closing..."
        close $sock
        return

    } elseif { $line eq "" } {
        #close $sock
        #puts "Close"
        return

    } else {
        #set match [regexp  {set} $line  match]; # find name key
        set command [lindex $line 0]
        if { $command == "sim" } {
            set result [proc_run_sim $line]
            puts $sock $result

        } elseif { $command == "set"} {
            set result [proc_fill_data $line]
            puts $sock $result

        } elseif { $command == "get" } {
            proc_send_data $sock $line

        } elseif { $command == "geta" } {
            proc_send_all_data $sock

        } elseif { $command == "cmd" } {
            proc_command $sock $line

        } elseif { $command == "raw" } {
            proc_raw_command $sock $line

        } elseif { $command == "quit" } {
            close $sock
            puts "Closing tcp socket."
            puts "exiting..."
            # quit -force
            exit
        }
        return
    }

}

proc proc_init_data {} {

    global input
    global output

    # create data entry for each name
    foreach {key data} [array get input] {
        set match [regexp  {path} $key  match]
        if {1 == $match} {
            set name [lindex [split $key ,] 0]
            set input($name,data) {}
        }
    }
    foreach {key data} [array get output] {
        set match [regexp  {path} $key  match]
        if {1 == $match} {
            set name [lindex [split $key ,] 0]
            set output($name,data) {}
        }
    }
}

proc proc_fill_data {line} {

    global input

    set name [lindex $line 1]
    set offset [lindex $line 2]
    set data [lrange $line 3 end]
    puts "Filling buffer : $name"
    set input($name,data) $data
    return "result OK"
}

proc proc_send_data {sock line} {

    global output

    set req_name [lindex $line 1]
    set offset [lindex $line 2]

    puts "Send buffer : $req_name"

    set searchToken [array startsearch output]
    while {[array anymore output $searchToken]} {
        set key [array nextelement output $searchToken]
        set match [regexp  {path} $key  match]; # find name key
        if {1 == $match} {
            set path $output($key)
            set name [lindex [split $key ,] 0]
            if { $req_name == $name } {
                catch {puts $sock "$output($name,data)"} result
                return
            }
        }
    }
    catch {puts $sock "err no $name in output array"} result

}

proc proc_send_all_data {sock} {

    global output

    set searchToken [array startsearch output]
    while {[array anymore output $searchToken]} {
        set key [array nextelement output $searchToken]
        set match [regexp  {path} $key  match]; # find name key
        if {1 == $match} {
            set path $output($key)
            set name [lindex [split $key ,] 0]
            catch {puts $sock "out $name $output($name,data)"} result
        }
    }

}

proc proc_run_sim {line} {

    global input
    global output

    set function [lindex $line 1]
    set steps [lindex $line 2]
    set stepTime [lrange $line 3 4]
    set step [lindex $line 3]
    set stepUnit [lindex $line 4]
    set usedata [lindex $line 5]
    set outstyle [lindex $line 6]
    set data 0

    # foreach {name data} [array get input] {
    #   puts "name : $name"
    #   puts "data : $data "
    #   set match [regexp {data} $name match]
    #   if {1 == $match} {
    #     puts [lindex  $data  3]

    #     # foreach d $data {
    #     #   puts "item : $d"


    #     # }
    #   }


    # }

    # clear output buffer before simulation starts
    # clear only if requested
    if { $outstyle == "clear" } {
        puts "Clearing output buffer..." 
        foreach {key data} [array get output] {
            set match [regexp  {path} $key  match]
            if {1 == $match} {
                set name [lindex [split $key ,] 0]
                set output($name,data) {}
            }
        }
    }

    puts "Running $steps x $stepTime..."

    # loop runs from 0 so steps -1
#    set steps [expr $steps - 1]

    # if no use of data is needed run just simulation steps with no data iteration
    if { $usedata == 0 } {
        for {set i 0} {$i < $steps} {incr i} {
            if { [ catch {
                run $step $stepUnit
            } err ] } { puts "error setting running sim $stepTime with no data"}
        }

    # if use of data is needed iterate over input/output buffers
    } else {
        for {set i 0} {$i < $steps} {incr i} {
            # set value for each input array element
            set searchToken [array startsearch input]
            while {[array anymore input $searchToken]} {
                set key [array nextelement input $searchToken]
                set match [regexp  {path} $key  match]; # find name key
                if {1 == $match} {
                    set path $input($key)
                    set name [lindex [split $key ,] 0]
                    set value [lindex $input($name,data)  $i]; # get data of the element
                    if { $value != "" } {
                        if { [ catch {
                            add_force -radix dec $path $value
                            #force -deposit $path [format %x $value]
                        } err ] } { puts "error setting  $path with velue $value : \n $err\n"}
                    }
                }
            }

            # collect data to output buffer
            set searchToken [array startsearch output]
            while {[array anymore output $searchToken]} {
                set key [array nextelement output $searchToken]
                set match [regexp  {path} $key  match]; # find name key
                if {1 == $match} {
                    set path $output($key)
                    set name [lindex [split $key ,] 0]
                    if { [ catch {
                        set data [get_value -radix dec $path]
                        #set data [examine -radix decimal $path]
                    } err ] } {  puts "error getting  $path \n $err\n"}
                    lappend output($name,data) $data
                    # puts "$name: $path: $data: $output($name,data)"
                }
            }

            # puts "Run simulation step $stepTime"
            if { [ catch {
                run $step $stepUnit
            } err ] } { puts "error running sim $stepTime : \n $err\n"}


        }
    }
    return "result OK"
}


proc proc_raw_command {sock line} {
    set command [lrange $line 1 end]
    puts "VSIM> $command"
    set result [eval $command]
    puts $sock $result
}

proc proc_command {sock line} {
    global now
    global Now

    set command [lindex $line 1]

    if { $command == "get_current_time"} {
        set unit [lindex $line 2]
        if { $unit == "1"} {
            puts $sock [current_time]
        } else {
            puts $sock [regexp -inline -- {-?\d+(?:\.\d+)?} [current_time]]
        }
    } elseif {$command == "restart"} {
        restart
        puts $sock "result OK"
    } else {
        puts $sock "result command unknown"
    }
}


# global input
# global output

# set  input(A,path)       P_I_DATA_A
# set  input(B,path)       P_I_DATA_B
# set  input(VALID,path)   P_I_VALID

# set  output(C,path)      P_O_DATA_C
# set  output(VALID,path)  P_O_VALID


# set searchToken [array startsearch input]
# while {[array anymore input $searchToken]} {
#     set key [array nextelement input $searchToken]
#     set match [regexp  {name} $key  match]
#     if {1 == $match} {
#         set name [lindex [split $key ,] 0]
#         set input($name,data) {123 2 4}
#     }

# }

# set  input(RESET,data) {11 12 13 14 15 16}
# set  input(A,data)  {21 22 23 24 25 26 27}

# puts $input(RESET,name)
# puts $input(RESET,data)
# puts $input(A,name)
# puts $input(A,data)

# set line {set A 1 2 3 4 5 6 7}



# foreach {name data} [array get input] {
#   puts "name : $name"
#   puts "data : $data "
#   set match [regexp {data} $name match]
#   if {1 == $match} {
#     puts [lindex  $data  3]

#     # foreach d $data {
#     #   puts "item : $d"


#     # }
#   }


# }

#modelsimServer 1234;



