# Blockxain

A naive blockchain implementation using Elixir for educational purpose only

## What is a blockchain?
Basically a blockchain is a growing list of blocks which are linked (a block points to it's prior sibling) with
each other and contains any kind of data in it. To be able to guarantee data consistence we can get the data plus
a timestamp and generate an hash to the block

```elixir
  hash = :crypto.hash(:sha256, data) |> Base.encode16
```

So our blocks are going to be like the blocks below, and more important if somehow the data got corruped we can easily
check that using the hash and the data

```elixir
  (:crypto.hash(:sha256, data_to_be_verified) |> Base.encode16) == hash
```

So this way we have our blockchain and we can trust that no data will be corruped 🎉.

```elixir
[
  #...

  # Block 2
  %{
    hash: "E65ED92B129940B9D89362D83BC1DC04425AC134DBA526BDD3FD11D07AE14AD0",
    data: "any kind of data can be stored here"
  },

  # Block 3
  %{
    hash: "7E51FBD75320FFEFCB5E0573C67DF823441D4C23E0829229F3F82FA35A0E0990",
    data: "any kind of data can be stored here also"
  }
]
```

But we still have a problem here, what if somebody takes a block; changes its data and simply regenerate the hash 🤔?
In this case the block would be considered valid, but our blockchain would be corrupted.

To fix it we can simply use the previous block hash appended with the data to generate the hash, this way if somebody
corrupts a block he/she have to recalculate the hash of all next blocks.

```elixir
  hash = :crypto.hash(:sha256, data <> previows_hash) |> Base.encode16
```

As you can see in the code above the block 3 points to the block 2 using the previows_hash attribute, and its own hash
was created using the data plus the previows_hash.

```elixir
[
  #...

  # Block 2
  %{
    hash: "E65ED92B129940B9D89362D83BC1DC04425AC134DBA526BDD3FD11D07AE14AD0",
    timestamp: 1510698296035,
    previows_hash: "ADC8AC2BF1D0E405A20EAD25E9A5BA446941FB4A79CE3BEACC765AE66C549C7C",
    data: "any kind of data can be stored here"
  },

  # Block 3
  %{
    hash: "7E51FBD75320FFEFCB5E0573C67DF823441D4C23E0829229F3F82FA35A0E0990",
    timestamp: 1510698306319,
    previows_hash: "E65ED92B129940B9D89362D83BC1DC04425AC134DBA526BDD3FD11D07AE14AD0",
    data: "any kind of data can be stored here also"
  }
]
```

This adds a little more complexity to malicious people who tries to corrupt our blockchains, but it is not enougth.
Generating a hash is very fast nowadays, using some fast hardware attackers could recreate all hashes in minutes.
In this case we should enforce people who generates the hash to spend a good amount of time and CPU effort to generate
the hash, and at the same time we should be able to verify the hash very quickly.

## Proof of Work

Proof of work is an algorithm that can be used when you requires that a user / system proofs that he spend some effort
(time and CPU) to execute something. A very naive implementation of this could be done using the own hash function we already
saw.

Generating a hash is fast of some data is very fast:

```
:crypto.hash(:sha256, "ola") |> Base.encode16
# => 55A9F4F8994B1BBF2058EA38C8EFB6C459000814D5F39C087002571639E6230E
```

But we can require that the hash starts with `"28"` (for instance), as the hash generated is always the same given this data
the user needs to change the data to generate other hashes and tries. The ideia then is append a nonce (a unique number) and
tries to find a hash that matches our challenge

```
:crypto.hash(:sha256, data <> "1") |> Base.encode16 # => "4CFC2263B5ADE5AE01ED784047E9FEC4029C0D2CB10BA79001A3ED2EF42F0D91"
:crypto.hash(:sha256, data <> "2") |> Base.encode16 # => "7812F001C07DE4D97485F912B33B4A57B75CBA3205F757AD888BAE92DCA42C88"
:crypto.hash(:sha256, data <> "3") |> Base.encode16 # => "7E2835C927A4BE25CAF6654A10FD856E661BF91457FAF0E2C5E8FD1BEC2B77DB"
:crypto.hash(:sha256, data <> "4") |> Base.encode16 # => "6AA5A9E5F64887B7A4C8A206A0478292BB125267690AFCDB2E19B42520C650D1"
:crypto.hash(:sha256, data <> "5") |> Base.encode16 # => "E9751FECB97DA01CB065A6057FC5A2B76259FBD602555122935A30A398696966"
:crypto.hash(:sha256, data <> "6") |> Base.encode16 # => "505D29080341DE336E977419B0D8E5FF6145FDD90880A098846290B39B3103CF"
:crypto.hash(:sha256, data <> "7") |> Base.encode16 # => "6932809DC4643207F47EFB483899B5CA43E5125F76827DBA6CD8505E93CFABF2"
:crypto.hash(:sha256, data <> "8") |> Base.encode16 # => "310C03BECF7ADDCBAC42AD387F6B4818C0C5BE954E408694AB91DB5CFE7814AB"
:crypto.hash(:sha256, data <> "9") |> Base.encode16 # => "EB3497EB40705CA192AA1E3347376836E68E10F08356B56AB3913651C283EEDC"
:crypto.hash(:sha256, data <> "10") |> Base.encode16 # => "E2DAA5A45109A218F9F510D17D34460FAC092F638907A619FEBB635224D84C37"
:crypto.hash(:sha256, data <> "11") |> Base.encode16 # => "40634735468E285577F9876A04C74BBDD75C542AE0F09CC926D534A8E3EF91EC"
:crypto.hash(:sha256, data <> "12") |> Base.encode16 # => "0FD4FF755505F2B019969EDBD9C8EC3B984AC2381E4BA0C8F18DF5ADD95883C3"
:crypto.hash(:sha256, data <> "13") |> Base.encode16 # => "77C897F5D86B8C39B78B12D743C19E640EBEDCD060F7EF60654DF6D0A9440AA1"
:crypto.hash(:sha256, data <> "14") |> Base.encode16 # => "E6E7BEF1C63D139AEBD28588CB1B031FB93392F8836646971DCFEF7ED13AC7C1"
:crypto.hash(:sha256, data <> "15") |> Base.encode16 # => "28D1C08992D346B301661FA7067BF767E1E9A2F83652C792DE44760F55E54A56"
```

In our case we were lucky, after only 15 rounds we found a winning hash.
