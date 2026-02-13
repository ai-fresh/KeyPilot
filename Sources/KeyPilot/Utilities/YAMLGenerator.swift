import Foundation

enum YAMLGenerator {
    static func generate(from mapping: KeyMapping) -> String {
        """
        orientation: normal
        rows: 1
        columns: 3
        knobs: 1
        layers:
          - buttons:
              - ["\(mapping.button1)", "\(mapping.button2)", "\(mapping.button3)"]
            knobs:
              - ccw: "\(mapping.knobCCW)"
                press: "\(mapping.knobPress)"
                cw: "\(mapping.knobCW)"
        """
    }
}
