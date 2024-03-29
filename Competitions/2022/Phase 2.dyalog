⍝ P1 Sub-space 
runs←{
    1∨.=(+\⍵)⍸⍤1⍳⍺
⍝               ⍳⍺  all indices
⍝       (+\⍵)       boundaries
⍝            ⍸⍤1    0 - below, 1 - between, 2 - above
⍝   1∨.=            where are the ones?
}

fill←{
    ⎕IO←0                     ⍝ nicer for this problem
    rank←≢size←⍺              ⍝ rank and size of the result
    vals←(×/size)⍴0           ⍝ raveled matrix of values
    amend←{
    ⍝ Function to modify vals as required
        start←rank↑⍵
        shape←rank↓⍵
        coords←shape⊤⍳×/shape     ⍝ all coordinates - fast version of ⍉↑,¨,⍳shape
        coords+⍤1 0←start-1       ⍝ increment to start position
        coords/⍨←size∧.>coords    ⍝ keep only the coordinates within bounds
        coords⊥⍨←size             ⍝ convert back to indices
        ⊢vals[coords]⊢←⍺          ⍝ set values
    }
    _←(1+⍳≢⍵)amend⍤0 1⊢⍵    ⍝ amend all values (discard amend results)
    size⍴vals               ⍝ reshape
}

subspaces←{
    ⎕IO←0 ⍝ Nicer for this problem
    size←⍴⍵
    flat←,⍵
    find←{
        where←(⊣/,⊢/)⍸⍺=⍵  ⍝ first and last index of the subspace
        coords←size⊤where  ⍝ convert to coords
        ,⍉1+-⍨\coords      ⍝ shape←1+-⍨\coords and start←1+⊣/coords
    }
    flat find⍤1 0⊢1+⍳⌈/flat  ⍝ Find all subspaces
}

⍝ P2 Reshape

reshape←{
    mat←(|⍺)⍴⍵  ⍝ reshape without reversals
    reverse_axis←{
    ⍝ Conditionally reverse
        elem axis←⍺
        ⌽[axis]⍣(elem<0)⊢⍵
    }
    ⊃reverse_axis/(⍺,¨⍳≢⍺),⊂mat ⍝ reverse each axis if required
}

reshape2←{
    s←⍺~⌊⍺                              ⍝ fractional values
    0≡≢s: ⍺ reshape ⍵                   ⍝ If no special values, use part 1
    ⍝ validity checking
    1<≢s:'Only 1 special value allowed'⎕SIGNAL 8
    ~0.5 1.5 2.5∊⍨|s←⊃s:'Special values can only be 0.5, 1.5, or 2.5'⎕SIGNAL 8

    n←×/⍴⍵                              ⍝ number of elements of ⍵
    whole←⍺~s                           ⍝ whole number axes
    axis←n÷×/|whole                     ⍝ what is the other axis?
    axis←{0.5=|s:⌊⍵ ⋄ ⌈⍵}axis           ⍝ floor if 0.5 else ceil
    axes←|axis@{s=⍵}⍺                   ⍝ create new axes
    data←{2.5=|s:(×/axes)↑,⍵ ⋄ ⍵}⍵      ⍝ pad with ↑ if 2.5=|s
    signed←axes××⍺                      ⍝ convert to original signs
    signed reshape data                 ⍝ use part 1 reshape
}

⍝ P3 Meetings

toTS←{⊃⊢⍤//'/: '⎕VFI⍵} ⍝ extract numbers from timestamp

Attended←{
    names←⍺[;1]
    names←names[grade←⍋names]                      ⍝ sort names, and store the grade
    mins←{'--'≡⍵:0⋄⌊1440×¯1 1⎕DT⊂¯1⌽@1 2 3⊢toTS ⍵} ⍝ convert the time to minutes
    join←mins¨⍺[grade;2]
    leave←mins¨⍺[grade;3]
    start←mins¨⍵[;3]
    end←mins¨⍵[;4]
    time←0⌈(leave∘.⌊end)-(join∘.⌈start)            ⍝ time in each session
    threshold←2÷⍨end-start                         ⍝ threshold for having attended
    total←names+⌿⍤⊢⌸time                           ⍝ sum the times grouping by names
    threshold≤⍤1⊢total                             ⍝ check above attending threshold
} 

ShowedUp←{
    map←⍉⍺ Attended ⍵                       ⍝ who attended what sessions, transposed for convenience
    names←⍺[grade←⍋⍺[;1];1]                 ⍝ Sort names and store the grade
    years←⊢/∘toTS¨⍺[grade;4]                ⍝ year for each attendee
    uniq←{⍵[⍋⍵]}∪years                      ⍝ unique years in sorted order (could hardcode 2020 and 2021)
    reg←⍉names{uniq∊⍵}⌸years                ⍝ which of the years did attendees register for
    e_yd←(↑toTS¨⊢/⍵)[;3 2]                  ⍝ year and day of each event (⍵ is in sorted order already)
    res←⍪uniq                               ⍝ result
    res,←+/reg                              ⍝ how many registered by year
    res,←2 2⍴e_yd{+/∨⌿⍵}⌸map                ⍝ how many attended, group by year + day
    res,reg{+/∧⌿⍺>⍤1⊢map⌿⍨⍵=⊣/e_yd}⍤¯1⊢uniq ⍝ how many attended none of the ones they were registered for
}

Popular←{
    years←(3⊃toTS)¨⊢/⍵                   ⍝ years of each session
    sessions←'break'∘≢¨⍵[;2]             ⍝ sessions that aren't breaks
    counts←(+⌿⍺),⍥⍪⍵[;2]                 ⍝ how many people attended each session
    years{⊂⍵[⍒⊣/⍵;]}⌸⍥(sessions⌿⊢)counts ⍝ filter breaks, group by year, sort descending
}

⍝ P4 Voting

rpart←{
    ⍝ A random partition of ⍺ into ⍵ parts
    ⍝ Based on the 'balls in cells' model
    ⍝ Example: Splitting 5 into 3 parts:
    ⍝ Required dividers = 2
    ⍝ Total possibilties = 2 + 5 = 7
    ⍝ 1 2 3 4 5 6 7
    ⍝ | | | | | | |   possible divider spots
    ⍝   2     5       randomly chosen spots
    ⍝ ○ | ○ ○ | ○ ○   balls in each cell
    ⍝ 1    2     2    1-⍨2-⍨/0,2 5,8

    ⍝ dividers ← {⍵[⍋⍵]} (⍵-1) ? (⍺+⍵-1)
    ⍝ dividers ← (⍳⍺+⍵-1) ~ ⍺ ? ⍺+⍵-1
    ⍝ Both are equivalent
    ⍝ Due to slowness in dyadic ? the second is faster if ⍺<⍵-1
    dividers←⍺{⍺>⍵-1:{⍵[⍋⍵]}(⍵-1)?(⍺+⍵-1) ⋄ (⍳⍺+⍵-1)~⍺?⍺+⍵-1}⍵

    ⍝ number of balls in each cell
    1-⍨2-⍨/0,dividers,⍺+⍵
}

Method1←{
    ⍝ Step 1: Generate all possible ballots
    ⍝ Step 2: Generate a random permutation of ⍵ into ≢ballots parts
    ⍝ This is efficient when |a is small (≤10), and therefore ≢ballots is reasonably small
    ⍝ For example, ¯3 Method1 1e9 is fast, but ¯3 Method2 1e9 is infeasibly slow

    pmat_all←{0=⍵:1 0⍴0 ⋄ ,[⍳2](⍒⍤1∘.=⍨⍳⍵)[;1,1+∇ ⍵-1]}
    ⍝ Generate a matrix with all rankings 1-n
    ⍝ Source: https://www.dyalog.com/blog/2015/07/permutations/
    pmat_any←{0=⍵:0 0⍴0 ⋄ ,[⍳2]((⊢,1+0⌈⌈/)0⍪∇⍵-1)[;⍋⍤⍋⍤1∘.=⍨⍳⍵]}
    ⍝ Generate a matrix with partial rankings 0-n
    ⍝ Not in lexicographic order, but that's ok for a selection
    ⍝ Code is based on the pmat_all code, but adapted
    ⍝ At each stage, the highest unused position (1+0⌈⌈/) is 'interleaved'
    ⍝        'abcd'[⍋⍤⍋⍤1∘.=⍨⍳4]
    ⍝  dabc
    ⍝  adbc
    ⍝  abdc
    ⍝  abcd

    ballots←{⍵<0:pmat_any|⍵ ⋄ pmat_all ⍵}⍺
    nb←≢ballots
    ⍝ Out of interest, there is a closed form
    ⍝ For positive ⍺, nb←!⍺
    ⍝ For negative ⍺, nb←1-⍨⌊(*1)×!|a

    ⍝ Generate a random permutation of ⍵ into nb parts
    r ← ⍵ rpart nb
    ⍝ return ballots chosen at least once and their frequencies
    r,⍥⊂⍤0 1⍥((r≠0)⌿⊢)ballots
}

Method2←{
    ⍝ This method generates ⍵ ballots at random and then counts the frequencies
    ⍝ It is more efficient for large |⍺ and small ⍵
    n←|⍺                                            ⍝ number of candidates
    ballots ← ?⍤0⍨⍵⍴n                               ⍝ rankings from 1-n for each
    ⍝ Given a random ballot x, say 1 4 2 3 5
    ⍝ x-3 is ¯2 1 ¯1 0 2
    ⍝ 0⌈x-3   0 1 0 0 2, which is a partially filled ballot
    ballots ← {0⌈⍵-⍤1 0⊢1-⍨?(≢⍵)⍴n}⍣(⍺≠n)⊢ ballots  ⍝ conditionally derank
    ,⍥⊆⍨∘≢⌸ ballots                                 ⍝ Count frequencies
}

Ballot←{
    10≥|⍺:⍺ Method1 ⍵ ⍝ Efficient for smallish ⍺ and large ⍵
    ⍺ Method2 ⍵ ⍝ Otherwise use Method2, efficient for large ⍺ and small ⍵
    ⍝ For large ⍺ and large ⍵ the total number of ballots grows quickly
    ⍝ As 'Every valid result should have a non-zero probability of appearing.', it seems infeasible
}

IRV←{
    freqs←⊣/⍵
    ranks←↑⊢/⍵
    process←{
        ⍝ ⍺ = candidates
        ⍝ ⍵ = ranks
        firsts←1=⍵                         ⍝ mark 1st choice candidates
        count←freqs+.×firsts               ⍝ count total votes
        p←(⊢÷+/)count                      ⍝ proportion
        0≠winner←⊃⍺/⍨0.5<p:winner          ⍝ if there is a winner, return it
        status←⍺,⍥⍪count                   ⍝ current status
        lowest←p=⌊/p                       ⍝ least voted
        ∧/lowest:status                    ⍝ if there is a tie, return the status
        remaining←~lowest                  ⍝ remaining people are whoever wasn't lowest
        adjusted←0⌈⍵-⍤1 0∨/lowest/firsts   ⍝ where they ranked a loser first, decrement rankings by 1
        status,⍥⊆⍺ ∇⍥(remaining/⊢)adjusted ⍝ return the status and the next phase
    }
    (⍳⊢/⍴ranks)process ranks              ⍝ do the process
}

⍝ P5 Base85

Encode←{
    ⎕IO←0                                  ⍝ base encodings work better with ⎕IO←0
    chunks←⌈4÷⍨≢⍵                          ⍝ number of chunks required
    padded←(4×chunks)↑⍵                    ⍝ pad data
    added←padded-⍥≢⍵                       ⍝ how many elements were added
    convert←,⍉(5/85)⊤256⊥⍉chunks 4⍴padded  ⍝ convert to base 85 from base 256
    ⍺[(-added)↓convert]                    ⍝ drop the number of added elements
}

Decode←{
    ⎕IO←0
    filtered←⍺⍳⍵∩⍺                        ⍝ Ordinal values of characters within charset
    chunks←⌈(≢filtered)÷5                 ⍝ Number of chunks
    added←(5×chunks)-≢filtered            ⍝ How many values need to be added
    padded←filtered,added⍴84              ⍝ Pad with 84s
    convert←,⍉(4/256)⊤85⊥⍉chunks 5⍴padded ⍝ Convert to base 85 and back to base 256
    (-added)↓convert                      ⍝ Drop the number of added values from the end
}

Base85←{
    0≡⊃0⍴⍵:⍺ Encode ⍵  ⍝ if ⍵ is numeric, encode
    ⍺ Decode ⍵         ⍝ otherwise decode
}

⍝ P6 Date

DDN←{
    ⎕FR←1287                      ⍝ Need more precision for this
    c←⍺⊂⍨(¯1⌽⍺≠'_')∧1,2≠/⎕C ⍺
    months←' '(≠⊆⊢)'January February March April May June July August September October November December'
    days←' '(≠⊆⊢)'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
    M D h m s w h y Y W←0
    parse←{
        0≡≢⍺:Y W y h m s
        ~(⎕D,⎕A)∊⍨1 ⎕C⊢/p←⊃⍺:(1↓⍺)∇((≢p)↓⍵)
        case←(⊂p)∊,¨
        ⍝ match on possible patterns
        case'M' 'MM' '_M':(1↓⍺)∇ n↓⍵⊣M⊢←⍎⍵↑⍨n←(≢p)⌈+/2↑⍵∊⎕D
        case'D' 'DD' '_D':(1↓⍺)∇ n↓⍵⊣D⊢←⍎⍵↑⍨n←(≢p)⌈+/2↑⍵∊⎕D
        case'h' 'hh' '_h':(1↓⍺)∇ n↓⍵⊣h⊢←⍎⍵↑⍨n←(≢p)⌈+/2↑⍵∊⎕D
        case'm' 'mm' '_m':(1↓⍺)∇ n↓⍵⊣m⊢←⍎⍵↑⍨n←(≢p)⌈+/2↑⍵∊⎕D
        case's' 'ss' '_s':(1↓⍺)∇ n↓⍵⊣s⊢←⍎⍵↑⍨n←(≢p)⌈+/2↑⍵∊⎕D
        case'w' 'ww' '_w':(1↓⍺)∇ n↓⍵⊣w⊢←⍎⍵↑⍨n←(≢p)⌈+/2↑⍵∊⎕D
        case't' 'tt' '_t':(1↓⍺)∇ n↓⍵⊣h⌈←12|⍎⍵↑⍨n←(≢p)⌈+/2↑⍵∊⎕D
        case'y' 'yy' '_y':(1↓⍺)∇ n↓⍵⊣y⊢←⍎⍵↑⍨n←1 3[≢p]⌈+/∧\3↑⍵∊⎕D
        case'YY' 'YYYY':(1↓⍺)∇ n↓⍵⊣Y⊢←⍎(n←≢p)↑⍵
        case'WW' 'WWWW':(1↓⍺)∇ n↓⍵⊣W⊢←⍎(n←≢p)↑⍵
        'o'∊⎕C p:(1↓⍺)∇((≢p)↓⍵)
        'p'∊⎕C p:(1↓⍺)∇((≢p)↓⍵)⊣h⊢←{⍵=0: h ⋄ h⌈24|h+12} 'p'∊⎕C (≢p)↑⍵
        case'd':(1↓⍺)∇(1↓⍵)
        case'MMM' 'Mmm' 'mmm' '_mm':     (1↓⍺)∇3↓⍵
        case'MMMM' 'Mmmm' 'mmmm' '_mmm': (1↓⍺)∇(≢months⊃⍨⊃⍸(⊃⍷⍥⎕C∘⍵)¨months)↓⍵
        case'DDD' 'Ddd' 'ddd' '_dd':     (1↓⍺)∇3↓⍵
        case'DDDD' 'Dddd' 'dddd' '_ddd': (1↓⍺)∇(≢days⊃⍨⊃⍸(⊃⍷⍥⎕C∘⍵)¨days)↓⍵
    }
    Y W y h m s←c parse ⍵
    days←y,(y=0)/⍳366             ⍝ possible days
    W⌈←Y
    years←(1⌈W+¯1 0 1),(W=0)/⍳10  ⍝ possible years
    ⍝ check if day/year combination is valid
    check←{0::⍬ ⋄ ⍵⍵≡⊃⍺⍺(1200⌶)dn←¯10 1 ⎕DT⊂⍺ ⍵ h m s:dn ⋄ ⍬}
    ⊃∊years∘.(⍺ check ⍵)days      ⍝ bruteforce
}
