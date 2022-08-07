# 2. Use a ECS

Date: 2022-08-07

## Status

Accepted

## Context

One of the target of the game is to be able to run 10.000 planets galaxy on a standard computer. This may require a very careful approch of the architecture. Naive implementation will very likely ends up with non-scalable galaxy size and limited planet amount.

## Decision

An ECS pattern will be used to handle most of the code. In particular the economic system that handle the planets.

The ECS is entitas.cr (see the shards.yml file).

## Consequences

Developer(s) need to know this unusual pattern.
Performance are expected very high and scalable with threads.
The architecture of most of the code will be defined and limited by the ECS pattern.
