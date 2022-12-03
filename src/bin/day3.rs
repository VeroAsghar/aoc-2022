use std::str::FromStr;

fn main() {
    println!("Hello, world!");
}

struct Rucksack {
    first: String,
    second: String
}

impl Rucksack {
    pub fn sum_priorities() {
        todo!();
    }

    fn find_repeat_char(&self) -> usize {
        self.first.chars().cmp
    }
}

impl FromStr for Rucksack {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (s1, s2) = s.split_at(s.len()/2);
        Ok(Rucksack {
            first: s1.to_string(),
            second: s2.to_string(),
        })
    }
}

#[cfg(test)]
mod test {
    use super::*;

    const INPUT: &str = "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw";

    #[test]
    fn example1() {
        let rucksacks = INPUT.lines().map(|line| line.parse().unwrap()).collect::<Vec<Rucksack>>();

    }
}
