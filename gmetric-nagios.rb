#!/bin/env ruby

# Remember to update these paths to point to your binaries!
stats_command = "/usr/nagios/bin/nagiostats -m -d "
gmetric_command = "/usr/bin/gmetric"

# If you want additional metrics that nagiosstats supports, add them to this array.
metrics = [
    { "mrtg" => "TOTCMDBUF", "name" => "buffer_slots_available" },
    { "mrtg" => "USEDCMDBUF", "name" => "buffer_slots_used" },
    { "mrtg" => "HIGHCMDBUF", "name" => "buffer_slots_max" },
    { "mrtg" => "NUMSERVICES", "name" => "total_services" },
    { "mrtg" => "NUMHOSTS", "name" => "total_hosts" },
    { "mrtg" => "NUMSVCOK", "name" => "services_state_ok" },
    { "mrtg" => "NUMSVCWARN", "name" => "services_state_warn" },
    { "mrtg" => "NUMSVCUNKN", "name" => "services_state_unknown" },
    { "mrtg" => "NUMSVCCRIT", "name" => "services_state_critical" },
    { "mrtg" => "NUMSVCSCHEDULED", "name" => "services_scheduled" },
    { "mrtg" => "NUMSVCFLAPPING", "name" => "services_flapping" },
    { "mrtg" => "NUMSVCDOWNTIME", "name" => "services_downtime" },
    { "mrtg" => "NUMHSTUP", "name" => "hosts_state_up" },
    { "mrtg" => "NUMHSTDOWN", "name" => "hosts_state_down" },
    { "mrtg" => "NUMHSTUNR", "name" => "hosts_state_unreachable" },
    { "mrtg" => "NUMHSTSCHEDULED", "name" => "hosts_scheduled" },
    { "mrtg" => "NUMHSTFLAPPING", "name" => "hosts_flapping" },
    { "mrtg" => "NUMHSTDOWNTIME", "name" => "hosts_downtime" },
    { "mrtg" => "AVGACTSVCLAT", "name" => "active_service_check_latency_avg", "ms_to_s" => true, "units" => "seconds" },
    { "mrtg" => "AVGACTSVCEXT", "name" => "active_service_check_exec_time_avg", "ms_to_s" => true, "units" => "seconds" },
    { "mrtg" => "AVGACTHSTLAT", "name" => "active_host_check_latency_avg", "ms_to_s" => true, "units" => "seconds" },
    { "mrtg" => "AVGACTHSTEXT", "name" => "active_host_check_exec_time_avg", "ms_to_s" => true, "units" => "seconds" },
]

all_metrics = []

metrics.each do |m|
    all_metrics << m['mrtg']
end

results = IO.popen("#{stats_command} #{all_metrics.join(',')}").readlines

i = 0
metrics.each do |metric|
    number = results[i].to_f

    if metric['ms_to_s'] == true
        number = number / 1000
    end

    units = metric['units'] ? metric['units'] : "number"

    puts "gmetric: #{metric['name']} (#{metric['mrtg']}) is #{number}"
    system "#{gmetric_command} -n nagios_#{metric['name']} -g nagios -v #{number} -t float -u #{units}"

    i = i + 1
end
