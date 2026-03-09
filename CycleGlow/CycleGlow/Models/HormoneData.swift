import Foundation

struct HormonePoint: Identifiable {
    let id = UUID()
    let day: Int
    let estrogen: Double
    let progesterone: Double
    let lh: Double
    let fsh: Double
}

struct HormoneData {
    static let cycle: [HormonePoint] = (1...28).map { day in
        HormonePoint(
            day: day,
            estrogen: estrogenLevel(day: day),
            progesterone: progesteroneLevel(day: day),
            lh: lhLevel(day: day),
            fsh: fshLevel(day: day)
        )
    }
    
    // Estrogen: rises in follicular, peaks at ovulation (day 13-14), drops, small luteal bump
    static func estrogenLevel(day: Int) -> Double {
        let d = Double(day)
        if day <= 5 { return 20 + d * 4 }
        if day <= 13 { return 40 + (d - 5) * 20 }
        if day == 14 { return 200 }
        if day <= 17 { return 200 - (d - 14) * 40 }
        if day <= 22 { return 80 + (d - 17) * 12 }
        return 140 - (d - 22) * 18
    }
    
    // Progesterone: low until ovulation, peaks mid-luteal (day 21-22), drops before period
    static func progesteroneLevel(day: Int) -> Double {
        let d = Double(day)
        if day <= 14 { return 2 + d * 0.3 }
        if day <= 21 { return 6 + (d - 14) * 14 }
        if day <= 24 { return 104 - (d - 21) * 5 }
        return 89 - (d - 24) * 20
    }
    
    // LH: low baseline, sharp spike at day 13-14 (ovulation trigger)
    static func lhLevel(day: Int) -> Double {
        let d = Double(day)
        if day <= 11 { return 8 + d * 0.5 }
        if day == 12 { return 20 }
        if day == 13 { return 70 }
        if day == 14 { return 55 }
        if day == 15 { return 15 }
        return 8 + (28 - d) * 0.2
    }
    
    // FSH: rises early follicular, small mid-cycle bump
    static func fshLevel(day: Int) -> Double {
        let d = Double(day)
        if day <= 3 { return 10 + d * 2 }
        if day <= 8 { return 16 - (d - 3) * 1.5 }
        if day <= 13 { return 8.5 + (d - 8) * 2 }
        if day == 14 { return 19 }
        if day <= 17 { return 19 - (d - 14) * 3 }
        return 7 + (28 - d) * 0.3
    }
}
