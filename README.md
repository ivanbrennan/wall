Guarding the North, the Wall spans hundreds of miles, it's icy face
dotted with castles and guarded by the Night's Watch. The men of
the Watch keep wildlings at bay by distributing rangers across the
castles in balance with the wildling population. But wildlings are
disorganized and tend to drift from castle to castle at random. To deal
with this, the rangers vary their patrols likewise.

The Wall is too vast for any one ranger to cover all of its castles.
Instead, each ranger has a territory he covers, ranging over a subset
of the castles. His territory overlaps with those of other rangers,
allowing the Night's Watch to dispatch its men flexibly.

No wildling is willing to stalk the entire length of the Wall looking
for holes in its defenses. Much like a ranger, an individual wildling
has a territory he stalks, testing the defenses of a subset of castles.

Note the symmetry: the many-to-many relation between wildlings and
castles mirrors that between rangers and castles.

```ruby
class Wildling < ActiveRecord::Base
  has_and_belongs_to_many :castles, join_table: :forays
end

class Castle < ActiveRecord::Base
  has_and_belongs_to_many :wildlings, join_table: :forays
  has_and_belongs_to_many :rangers,   join_table: :patrols
end

class Ranger < ActiveRecord::Base
  has_and_belongs_to_many :castles, join_table: :patrols
end
```

The underlying schema looks something like this,

```
                                  ||~~~||
                                  ||~~~||
                                  ||~~~||
                                  ||~~~||
               +-----------+    +---------+    +---------+
+---------+    |forays     |    |castles  |    |patrols  |    +---------+
|wildlings|    +-----------+    +---------+    +---------+    |rangers  |
+---------+    |castle_id  |>---|id       |---<|castle_id|    +---------+
|id       |---<|wildling_id|    |name     |    |ranger_id|>---|id       |
|name     |    +-----------+    +---------+    +---------+    |name     |
+---------+                       ||~~~||                     +---------+
                                  ||~~~||
                                  ||~~~||
```

A castle may be in *equilibrium*, *under-defended*, or *over-defended*,
depending on the ratio of rangers to wildlings. *Equilibrium* means the
same number of rangers regularly visit the castle as do wildlings.
This is what the Night's watch aims for, as it allows them to protect
the Wall without wasting resources. If there are fewer rangers than
wildlings, the castle is *under-defended*. It will be overrun and nearby
villages plundered. If there are more rangers than wildlings, it's
*over-defended*. It's safe, but at the expense of the Wall as a whole,
leaving fewer defenders for other castles.

Querying for under-defended|equilibrium|over-defended castles is
relatively straightforward. Consider the under-defended case, "Show me
which castles have fewer rangers defending them than they do wildlings
attacking them":
```sql
  SELECT castles.*
  FROM castles
  JOIN patrols ON patrols.castle_id = castles.id
  JOIN forays  ON forays.castle_id  = castles.id
  GROUP BY castles.id
  HAVING COUNT(patrols.ranger_id) < COUNT(forays.wildling_id);
```

If we change the `<` to `>`, we get the over-defended castles, and `=`
gives us castles in equilibrium.

What if we'd like to gauge which wildlings are most likely to break
through the Wall's defenses? That is, which wildlings can rightly say
their territory is under-defended overall.

One way we might answer that is by considering the subset of castles a
wildling harasses (his territory). How many rangers have territories
that overlap this subset? We could consider this a measure of its
defenses. How many wildlings have territories that overlap this subset?
We could consider this a measure of its beseigement. Comparing these two
measures lets us say whether a particular wildling is likely to be a successful
raider.

We'd perform this comparison for each wildling, but let's first focus
on a single one and determine if he should be included in the "most
dangerous" category of his kinsfolk.

An important consideration is whether we should count a ranger more than
once per wildling-territory if they patrol more than one of its castles.
On the one hand, they can only be in one place at a time, so we might
want to count only distinct rangers. On the other hand, a ranger who
divides his time among the exact subset of castles we're considering
should count for more than one who's territory barely overlaps, as
the first ranger is more likely to be present at whichever castle the
wildling decides to strike. The same applies to how we count the wildling's
kinsfolk: a fellow-attacker is more likely to be of aid if they're attacking the
same castle, which is more likely to be the case the more their own territory
overlaps with the attacker's territory.
