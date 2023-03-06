module TETU::Helpers::Numbers
  BILLION  = 1_000_000_000
  MILLION  =     1_000_000
  THOUSAND =         1_000

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

struct Number
  def billions
    self * TETU::Helpers::Numbers::BILLION
  end

  def millions
    self * TETU::Helpers::Numbers::MILLION
  end

  def thousands
    self * TETU::Helpers::Numbers::THOUSAND
  end
end
