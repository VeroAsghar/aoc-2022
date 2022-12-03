use std::str::FromStr;

fn main() {
    const INPUT: &str = include_str!("day3.input");
    let lines: Vec<String> = INPUT.lines().map(|line| line.to_string()).collect();
    let nr_of_groups = lines.len() / 3;
    let mut lines = lines.iter();

    let groups = (0..nr_of_groups).into_iter().map(|_| {
        Group::parse(&mut lines.by_ref().take(3))
    }).inspect(|g| {
        println!("{:?}", g)
    }).collect::<Vec<Group>>();

    let sum_priorities: usize = groups.into_iter().map(|group| priority(group.find_repeat())).sum();
    println!("{}", sum_priorities);
}

struct Rucksack {
    first: String,
    second: String
}

impl Rucksack {

    fn find_repeat(&self) -> char {
        let c1: Vec<char> = self.first.chars().collect();
        let c2: Vec<char> = self.second.chars().collect();
        for i in &c1 {
            for j in &c2 {
                if *i == *j {
                    return *i
                }
            }
        }
        panic!();
    }

}

#[derive(Debug)]
struct Group {
    first: String,
    second: String,
    third: String,
}

pub fn priority(c: char) -> usize {
    let mut letters: Vec<char> = ('a'..='z').into_iter().collect::<Vec<char>>();
    let uppercase: Vec<char> = ('A'..='Z').into_iter().collect::<Vec<char>>();
    letters.extend(uppercase);
    letters.into_iter().position(|x| x == c).unwrap() + 1

}
impl Group {
pub fn find_repeat(&self) -> char {
    let c1: Vec<char> = self.first.chars().collect();
    let c2: Vec<char> = self.second.chars().collect();
    let c3: Vec<char> = self.third.chars().collect();
    for i in &c1 {
        for j in &c2 {
            for k in &c3 {
                if *i == *j && *i == *k {
                    return *i
                }
            }
        }
    }
    panic!();
}
    pub fn parse<'a, I: Iterator<Item=&'a String>>(iter: &mut I) -> Self {
        Group {
            first: iter.next().unwrap().to_string(),
            second: iter.next().unwrap().to_string(),
            third: iter.next().unwrap().to_string(),
        }
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
        let sum_priorities = INPUT.lines().map(|line| priority(line.parse::<Rucksack>().unwrap().find_repeat())).sum::<usize>();
        assert_eq!(sum_priorities, 157);

    }

    #[test]
    fn example2() {
        let lines: Vec<String> = INPUT.lines().map(|line| line.to_string()).collect();
        let nr_of_groups = lines.len() / 3;
        let mut lines = lines.iter();

        let groups = (0..nr_of_groups).into_iter().map(|_| {
            Group::parse(&mut lines.by_ref().take(3))
        }).inspect(|g| {
            println!("{:?}", g)
        }).collect::<Vec<Group>>();

        let sum_3_priorites: usize = groups.into_iter().map(|group| priority(group.find_repeat())).sum();
        assert_eq!(sum_3_priorites, 70);
    }
}
