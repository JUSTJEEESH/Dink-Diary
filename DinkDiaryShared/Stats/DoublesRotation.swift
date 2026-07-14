import Foundation

/// Doubles rotation memory. Given the four on court last game (you, your partner,
/// and two opponents), this cycles to the next pairing so "swap partners" is one
/// tap. Across three swaps every player has partnered you once, the natural
/// open-play rotation.
enum DoublesRotation {
    /// The next pairing: your old first opponent becomes your partner, and your
    /// old partner joins the other opponent across the net. Returns nil unless
    /// there were exactly two opponents to rotate.
    static func next(partner: Player?, opponents: [Player]) -> (partner: Player, opponents: [Player])? {
        guard let partner, opponents.count == 2 else { return nil }
        let newPartner = opponents[0]
        let newOpponents = [opponents[1], partner]
        return (newPartner, newOpponents)
    }
}
