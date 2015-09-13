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

We might want to refine this query, giving less weight to patrols made by
rangers whose duties spread them too thin. We could say the value of a
particular ranger's patrol is inversely proportional to the number of patrols
they do. If they dedicate themselves to a single castle, they add significant
defensive value there, whereas ranging across a dozen different castles spreads
that value thin across a larger territory. We can apply this principle to the
attackers as well as the defenders.

This requires a more complex query, so let's think at first from the
perspective of a single castle, Castle Black. Starting at the castle,
```sql
SELECT castles.*
FROM castles
WHERE castles.name = "Castle Black"
```
we consider its patrols,
```sql
SELECT patrols.*
FROM castles
JOIN patrols ON patrols.castle_id = castles.id
WHERE castles.name = "Castle Black"
```
in order to find all of its patrolling rangers.
```sql
SELECT rangers.*
FROM castles
JOIN patrols ON patrols.castle_id = castles.id
JOIN rangers ON patrols.ranger_id = rangers.id
WHERE castles.name = "Castle Black"
```
Once we've made it from Castle Black to all of its potential defenders, we need
to consider how much territory each of those rangers patrols. We can do so by
rejoining the patrols table on `ranger_id`.
```sql
SELECT pt2.*
FROM castles
JOIN patrols ON patrols.castle_id = castles.id
JOIN rangers ON patrols.ranger_id = rangers.id
JOIN patrols pt2 ON pt2.ranger_id = rangers.id
WHERE castles.name = "Castle Black"
```
This gives us the pool of all patrols made by the rangers that patrol Castle
Black. We'd like to group these by ranger to see how many castles each ranger is
patrolling.
```sql
SELECT COUNT(pt2.castle_id)
FROM castles
JOIN patrols ON patrols.castle_id = castles.id
JOIN rangers ON patrols.ranger_id = rangers.id
JOIN patrols pt2 ON pt2.ranger_id = rangers.id
WHERE castles.name = "Castle Black"
GROUP BY rangers.id
```
Inverting this count gives us a measure of each ranger's value on a per-patrol
basis.
```sql
SELECT (1 / COUNT(pt2.castle_id)) as defense_val
FROM castles
JOIN patrols ON patrols.castle_id = castles.id
JOIN rangers ON patrols.ranger_id = rangers.id
JOIN patrols pt2 ON pt2.ranger_id = rangers.id
WHERE castles.name = "Castle Black"
GROUP BY rangers.id
```
We can similarly calculate the danger each wildling presents to Castle Black,
```sql
SELECT (1 / COUNT(fo2.castle_id)) as attack_val
FROM castles
JOIN forays ON forays.castle_id = castles.id
JOIN wildlings ON forays.wildling_id = wildlings.id
JOIN forays fo2 ON fo2.wildling_id = wildlings.id
WHERE castles.name = "Castle Black"
GROUP BY wildlings.id
```

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
