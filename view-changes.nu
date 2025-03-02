export def main [
    data: table<key: string, value: string, header: string>
    --ignore-nulls # Flag to ignore null values; if absent, nulls become "null" and are highlighted when changing from non-null
] {
    try {
        let processed = ($data
            | polars into-df
            | polars pivot --on [header] --index [key] --values [value]
            | polars into-nu)

        # Feature 1: Filter rows where value changes at least once
        let filtered = ($processed | where { |row|
            mut values = ($row | reject key | values)
            if not $ignore_nulls {
                # Replace nulls with "null" when flag is absent
                $values = ($values | each { |v| $v | default "null" })
            } else {
                # Ignore nulls when flag is present
                $values = ($values | filter { |v| $v != null })
            }
            ($values | uniq | length) > 1  # Check if there’s more than one unique value
        })

        # Feature 2: Highlight changes with cycling colors
        let colors = [
            "48;5;226m", # Yellow background
            "48;5;208m", # Orange background
            "48;5;196m", # Red background
            "48;5;46m",  # Green background
            "48;5;27m"   # Blue background
        ] # Add more colors if needed
        let highlighted = ($filtered | each { |row|
            mut values = ($row | reject key | values)
            if not $ignore_nulls {
                $values = ($values | each { |v| $v | default "null" })
            } else {
                $values = ($values | filter { |v| $v != null })
            }
            let headers = ($row | reject key | columns)
            mut styled_row = { key: $row.key }
            mut color_index = 0 # Start with first color
            for $i in 0..($values | length | $in - 1) {
                let curr_value = ($values | get $i)
                let header = ($headers | get $i)
                let styled_value = if $i > 0 and $curr_value != ($values | get ($i - 1)) {
                    # Use next color for each change
                    let color = ($colors | get ($color_index mod ($colors | length)))
                    $color_index = $color_index + 1
                    $"(ansi -e $color)($curr_value)(ansi reset)"
                } else {
                    $curr_value # No highlight if no change
                }
                $styled_row = ($styled_row | insert $header $styled_value)
            }
            $styled_row
        })

        $highlighted | table
    } catch { |e| 
        print $e
    }
}