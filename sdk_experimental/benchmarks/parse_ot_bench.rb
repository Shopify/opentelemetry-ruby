require 'benchmark/ipsa'

DECIMAL = /\A\d+\z/

def decimal(str)
  str.to_i if !str.nil? && DECIMAL.match?(str)
end

def parse(ot)
  p = r = nil
  rest = +''
  ot.split(';').each do |field|
    k, v = field.split(':', 2)
    # TODO: "the used keys MUST be unique." - do we need to validate this?
    case k
    when 'p' then p = decimal(v)
    when 'r' then r = decimal(v)
    else
      rest << ';' unless rest.empty?
      rest << field
    end
  end
  rest = nil if rest.empty?

  [p, r, rest]
end

def parse_fast(ot)
  # Fast-path parser that avoids most intermediate allocations.
  # It scans the string once, extracting the integer values for the
  # `p` and `r` keys and collecting the remaining segments.
  p = r = nil
  rest = nil

  i   = 0
  len = ot.length

  while i < len
    # Find the end of the current field (either `;` or end of string)
    j = ot.index(';', i) || len

    # Field boundaries are now [i, j)
    field_len = j - i

    if field_len >= 2 && ot.getbyte(i + 1) == 58 # 58 == ':'
      key_byte = ot.getbyte(i)
      val_start = i + 2

      # Fast-path only if key is 'p' or 'r'
      if (key_byte == 112 || key_byte == 114) # 'p' or 'r'
        num = 0
        k   = val_start
        valid = false
        while k < j
          byte = ot.getbyte(k)
          if byte >= 48 && byte <= 57 # '0'..'9'
            num = num * 10 + (byte - 48)
            valid = true
            k += 1
          else
            valid = false
            break
          end
        end

        if valid
          if key_byte == 112 # 'p'
            p = num
          else # 'r'
            r = num
          end
        else
          # Not a valid decimal value, treat as generic field
          if rest
            rest << ';'
            rest << ot[i, field_len]
          else
            rest = ot[i, field_len].dup
          end
        end
      else
        # Unknown key, copy to rest
        if rest
          rest << ';'
          rest << ot[i, field_len]
        else
          rest = ot[i, field_len].dup
        end
      end
    else
      # No colon or too short to be key:value, copy to rest
      if rest
        rest << ';'
        rest << ot[i, field_len]
      else
        rest = ot[i, field_len].dup
      end
    end

    i = j + 1 # Move past the semicolon (or to len, which is fine)
  end

  # Align semantics with the original parse: return nil if no extra fields.
  rest = nil if rest&.empty?

  [p, r, rest]
end

Benchmark.ipsa do |x|
  x.report('parse') { parse('p:1;r:62;foo=bar') }
  x.report('parse_fast') { parse_fast('p:1;r:62;foo=bar') }

  x.compare!
end