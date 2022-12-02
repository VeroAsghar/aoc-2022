fn main() {
    println!("{}", total_score2(parse_rounds(include_str!("day2.input"))));
}

pub struct Round {
    pub opponent: String,
    pub player: String,
}

pub fn parse_rounds(input: &str) -> Vec<Round> {
    input.lines().map(|round| Round::from(round)).collect()
}

impl From<&str> for Round {
    fn from(input: &str) -> Self {
        let Some((p1, p2)) = input.split_once(' ') else {
            panic!("could not parse players from round");
        };
        Self {
            opponent: p1.to_string(),
            player: p2.to_string(),
        }
    }
}
impl Round {
    pub fn assign_score1(&mut self) -> usize {
        let c1 = self.opponent.pop().unwrap();
        let c2 = self.player.pop().unwrap();


        let move1 = Move::from(c1);
        let move2 = Move::from(c2);

        let player_score = match c2 {
            'X' => 1,
            'Y' => 2,
            'Z' => 3,
            _ => panic!(),
        };

        player_score + round_score(move1, move2)
    }
    pub fn assign_score2(&mut self) -> usize {
        let c1 = self.opponent.pop().unwrap();
        let c2 = self.player.pop().unwrap();


        let move1 = Move::from(c1);


        let move2 = Move::correct_move(move1, c2);
        let player_score = match move2 {
            Move::Rock => 1,
            Move::Paper => 2,
            Move::Scissors => 3,
        };

        player_score + round_score(move1, move2)
    }
}

#[derive(PartialEq, Eq, Clone, Copy)]
enum Move {
    Rock,
    Paper,
    Scissors,
}

impl Move {
    pub fn winning_move(&self) -> Self {
        match self {
            Move::Rock => Move::Paper,
            Move::Paper => Move::Scissors,
            Move::Scissors => Move::Rock,
        }
    }
    pub fn losing_move(&self) -> Self {
        match self {
            Move::Rock => Move::Scissors,
            Move::Paper => Move::Rock,
            Move::Scissors => Move::Paper,
        }
    }
    pub fn correct_move(m: Move, c: char) -> Self {
        match c {
            'X' => m.losing_move(),
            'Y' => m,
            'Z' => m.winning_move(),
            _ => unreachable!(),
        }

    }
}

impl From<char> for Move {
    fn from(c: char) -> Self {
        match c {
            'A' | 'X' => Self::Rock,
            'B' | 'Y' => Self::Paper,
            'C' | 'Z' => Self::Scissors,
            _ => unreachable!(),
        }
    }
}

fn round_score(m1: Move, m2: Move) -> usize {
    if m1 == m2 {
        return 3;
    }

    match (m1, m2) {
        (Move::Rock, Move::Paper) => 6,
        (Move::Rock, Move::Scissors) => 0,
        (Move::Paper, Move::Rock) => 0,
        (Move::Paper, Move::Scissors) => 6,
        (Move::Scissors, Move::Rock) => 6,
        (Move::Scissors, Move::Paper) => 0,
        _ => unreachable!(),
    }
}

pub fn total_score1(rounds: Vec<Round>) -> usize {
    rounds.into_iter().map(|mut round| round.assign_score1()).sum()
}
pub fn total_score2(rounds: Vec<Round>) -> usize {
    rounds.into_iter().map(|mut round| round.assign_score2()).sum()
}

#[cfg(test)]
mod test {
    use super::*;

    const TEST_INPUT: &str = "A Y
B X
C Z";

    #[test]
    fn example1() {
        let rounds = parse_rounds(TEST_INPUT);
        assert_eq!(total_score1(rounds), 15);
    }
    #[test]
    fn example2() {
        let rounds = parse_rounds(TEST_INPUT);
        assert_eq!(total_score2(rounds), 12);
    }
}
