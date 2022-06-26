module TETU::Helpers::Numbers
  BILLION = 1_000_000_000
  MILLION = 1_000_000
  THOUSAND = 1_000

  def self.humanize(number, round = 2)
    if number > BILLION
      "#{(number / BILLION).round(round)}B"
    elsif number > MILLION
      "#{(number / MILLION).round(round)}M"
    elsif number > THOUSAND
      "#{(number / THOUSAND).round(round)}K"
    else
      number.round(round).to_s
    end
  end
end
