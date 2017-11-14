defmodule Blockxain.MerkleTreeTest do
  use ExUnit.Case

  alias Blockxain.MerkleTree

  test "generates a merkle tree from hashes" do
    hash = fn data -> :crypto.hash(:sha256, "#{data}") |> Base.encode16 end

    with hashes <- [hash.(1), hash.(2), hash.(3), hash.(4), hash.(5)],
         mk <- MerkleTree.create(hashes) do

      assert mk == %MerkleTree{
        hash: "E65ED92B129940B9D89362D83BC1DC04425AC134DBA526BDD3FD11D07AE14AD0",
        children: [
          %{
            hash: "7E51FBD75320FFEFCB5E0573C67DF823441D4C23E0829229F3F82FA35A0E0990",
            children: [
              %{
                hash: "ADC8AC2BF1D0E405A20EAD25E9A5BA446941FB4A79CE3BEACC765AE66C549C7C",
                children: [
                  %{hash: "5BD29D071C90BA120BA72B7B3E866D1D7A87ADEB7FB0397D463B4A8F4FE75EBC"},
                  %{hash: "2AF51DBA24319611F560ADB7E607001A000E0C4C8AEB6BBBE169A04A4A519281"}
                ]
              },
              %{
                hash: "241231927BB5C900D8832C8C6CDD3DA449D140E3C88E8C8C5FE0BEF672002191",
                children: [
                  %{hash: "32144A819A940E8717EF0C1EAA576949318508126372BAF8B5583FAB769883BB"},
                  %{hash: "7B421D4C4ACB379B160FD80E08DBC127620D132FB50EDCC11D92FA9B4C5E9A97"}
                ]
              }
            ]
          },
          %{
            hash: "00DE7F6D23A9A39F8FEF9086533038D54E0DE7060E55B02F7313DD58A807EC0A",
            children: [
              %{
                hash: "65A78D1ED9C1AE7948BFA0B6D6893BB227EAA950B7A9CC8EE3E8FD9A5BB7EF69",
                children: [
                  %{hash: "1ECF7EAE8978C831D79BB0D040AABA98796742829E2F8C587D9CAA907236E898"}
                ]
              }
            ]
          }
        ]
      }
    end
  end
end
