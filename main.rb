FrequencyValues = Struct.new(:freq, :swr, :gaindbi )

CableValues = Struct.new(:k1, :k2)

def CalculateReflectionCoefficient(freqvals)
    ((freqvals.swr - 1)/(freqvals.swr + 1)).abs
end

def CalculateFeedlineLossForMatchedLoadAtFrequency(feedline_length, feedline_loss_per_100ft_at_frequency)
    (feedline_length/100.0) * feedline_loss_per_100ft_at_frequency
end

def CalculateFeedlineLossForMatchedLoadAtFrequencyPct(feedline_loss_for_matched_load_at_frequency)
    10**(-feedline_loss_for_matched_load_at_frequency/10)
end

def CalculateFeedlineLossPer100ftAtFrequency(freqvals, cablevals)
    cablevals.k1 * Math.sqrt(freqvals.freq + cablevals.k2 * freqvals.freq)
end

def CalculateFeedlineLossForSWR(feedline_loss_for_matched_load_percentage, gamma_squared)
    -10 * Math.log10(feedline_loss_for_matched_load_percentage * ((1 - gamma_squared)/(1 - feedline_loss_for_matched_load_percentage**2 * gamma_squared)))
end

def CalculateFeedlineLossForSWRPercentage(feedline_loss_for_swr)
    (100 - 100/(10**(feedline_loss_for_swr/10)))/ 100
end

def CalculateUncontrolledSafeDistance(freqvals, cablevals, xmtr_power, feedline_length, duty_cycle, per_30)
    gamma = CalculateReflectionCoefficient(freqvals)
    feedline_loss_per_100ft_at_frequency = CalculateFeedlineLossPer100ftAtFrequency(freqvals, cablevals)
    feedline_loss_for_matched_load_at_frequency = CalculateFeedlineLossForMatchedLoadAtFrequency(feedline_length, feedline_loss_per_100ft_at_frequency)   
    feedline_loss_for_matched_load_at_frequency_percentage = CalculateFeedlineLossForMatchedLoadAtFrequencyPct(feedline_loss_for_matched_load_at_frequency)
    gamma_squared = (gamma**2).abs
    feedline_loss_for_swr = CalculateFeedlineLossForSWR(feedline_loss_for_matched_load_at_frequency_percentage, gamma_squared)
    feedline_loss_for_swr_percentage = CalculateFeedlineLossForSWRPercentage(feedline_loss_for_swr)
    power_loss_at_swr = feedline_loss_for_swr_percentage * xmtr_power
    peak_envelope_power_at_antenna = xmtr_power - power_loss_at_swr
    uncontrolled_average_pep = peak_envelope_power_at_antenna * duty_cycle * per_30
    mpe_s = 180 / (freqvals.freq**2)
    gain_decimal = 10**(freqvals.gaindbi/10)
    Math.sqrt((0.219 * uncontrolled_average_pep * gain_decimal) / mpe_s)
end

def main
    xmtr_power = 1000
    feedline_length = 73
    duty_cycle = 0.5
    per_30 = 0.5
    cablevals = CableValues.new(0.122290, 0.000260)

    all_frequency_values = [
        FrequencyValues.new(7.3, 2.25, 1.5),
        FrequencyValues.new(14.35, 1.35, 1.5),
        FrequencyValues.new(18.1, 3.7, 1.5),
        FrequencyValues.new(21.45, 4.45, 1.5),
        FrequencyValues.new(24.99, 4.1, 1.5),
        FrequencyValues.new(29.7, 2.18, 4.5)
    ]
    
   all_frequency_values.each do |f|
       yup = CalculateUncontrolledSafeDistance(f, cablevals, xmtr_power, feedline_length, duty_cycle, per_30)
       puts "%0.2f" % [yup]
   end

end

main