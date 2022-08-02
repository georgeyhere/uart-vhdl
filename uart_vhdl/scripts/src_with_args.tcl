proc src {file args} {
   set argv $::argv
   set argc $::argc
   set ::argv $args
   set ::argc [llength $args]
   set error [catch {uplevel [list source $file]} return]
   if { $error } { set code error } { set code ok }
   set ::argv $argv
   set ::argc $argc
   return -code $code $return
 }