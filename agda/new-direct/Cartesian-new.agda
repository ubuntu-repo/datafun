module Cartesian-new where

open import Level
open import Data.Product using (_×_; _,_; proj₁; proj₂; <_,_>)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Relation.Binary using (Rel)

open import Cat


---------- Constructions on "relations" & categories ----------
rel× : ∀{i j k l A B} (R : Rel {i} A j) (S : Rel {k} B l) -> Rel (A × B) _
rel× R S (a , x) (b , y) = R a b × S x y

data rel+ {i j k l A B} (R : Rel {i} A j) (S : Rel {k} B l) : Rel (A ⊎ B) (j ⊔ l) where
  rel₁ : ∀{a b} -> R a b -> rel+ R S (inj₁ a) (inj₁ b)
  rel₂ : ∀{a b} -> S a b -> rel+ R S (inj₂ a) (inj₂ b)

cat× cat+ : ∀{i j k l} -> Cat i j -> Cat k l -> Cat _ _
Obj (cat× C D) = Obj C × Obj D
Arr (cat× C D) = rel× (Arr C) (Arr D)
ident (cat× C D) = ident C , ident D
compo (cat× C D) (f1 , g1) (f2 , g2) = compo C f1 f2 , compo D g1 g2

Obj (cat+ C D) = Obj C ⊎ Obj D
Arr (cat+ C D) = rel+ (Arr C) (Arr D)
ident (cat+ C D) {inj₁ _} = rel₁ (ident C)
ident (cat+ C D) {inj₂ _} = rel₂ (ident D)
compo (cat+ C D) (rel₁ x) (rel₁ y) = rel₁ (compo C x y)
compo (cat+ C D) (rel₂ x) (rel₂ y) = rel₂ (compo D x y)


---------- Properties of / structures on categories ----------
record Products {i j} (C : Cat i j) (_∧_ : (a b : Obj C) -> Obj C) : Set (i ⊔ j) where
  constructor Products:
  private instance cc = C
  field π₁ : ∀{a b} -> a ∧ b ≤ a
  field π₂ : ∀{a b} -> a ∧ b ≤ b
  infix 4 ⟨_,_⟩
  field ⟨_,_⟩ : ∀{a b c} -> a ≤ b -> a ≤ c -> a ≤ b ∧ c

  swap : ∀{a b} -> a ∧ b ≤ b ∧ a
  swap = ⟨ π₂ , π₁ ⟩

  ×-map : ∀{a₁ b₁ a₂ b₂} -> a₁ ≤ a₂ -> b₁ ≤ b₂ -> a₁ ∧ b₁ ≤ a₂ ∧ b₂
  ×-map f g = ⟨ π₁ • f , π₂ • g ⟩

  ∇ : ∀{a} -> a ≤ a ∧ a
  ∇ = ⟨ id , id ⟩

record Sums {i j} (C : Cat i j) (_∨_ : (a b : Obj C) -> Obj C) : Set (i ⊔ j) where
  constructor Sums:
  private instance cc = C
  field in₁ : ∀{a b} -> a ≤ a ∨ b
  field in₂ : ∀{a b} -> b ≤ a ∨ b
  field [_,_] : ∀{a b c} -> a ≤ c -> b ≤ c -> a ∨ b ≤ c

-- TODO: exponentials
record Closed {i j} (C : Cat i j) (_⊗_ _⇨_ : (a b : Obj C) -> Obj C) : Set (i ⊔ j) where
  constructor Closed:
  private instance cc = C
  field apply : ∀{a b} -> (a ⇨ b) ⊗ a ≤ b
  field curry : ∀{a b c} -> a ⊗ b ≤ c -> a ≤ b ⇨ c

record Exponentials {i j} (C : Cat i j) {_∧_} (P : Products C _∧_)
                    (_⇨_ : (a b : Obj C) -> Obj C) : Set (i ⊔ j) where
  constructor Exponentials:
  private instance cc = C
  field apply : ∀{a b} -> (a ⇨ b) ∧ a ≤ b
  field curry : ∀{a b c} -> a ∧ b ≤ c -> a ≤ b ⇨ c


-- Expose Products & Sums methods with appropriate instance arguments.
module _ {i j Obj Arr} {{C : Compose {i}{j} Obj Arr}} where
  module _ {_⊗_} {{Prod : Products (cat C) _⊗_}} where
    open Products Prod public
    infixr 2 _∧_; _∧_ = _⊗_

    -- module _ {hom} {{Exp : Closed (cat C) _⊗_ hom}} where
    --   open Closed Exp public
    --   infixr 4 _⇨_; _⇨_ = hom

    module _ {hom} {{Exp : Exponentials (cat C) Prod hom}} where
      open Exponentials Exp public
      infixr 4 _⇨_; _⇨_ = hom

  module _ {_⊕_} {{Sum : Sums (cat C) _⊕_}} where
    open Sums Sum public
    infixr 3 _∨_; _∨_ = _⊕_

  -- module _ {_⊗_ hom} {{Clo : Closed (cat C) _⊗_ hom}} where
  --   open Closed Clo public
  --   infixr 4 _⇨_; _⇨_ = hom


-- Instances for cat:set and cat:cat
instance
  products:set : ∀{i} -> Products (cat:set {i}) _×_
  products:set = Products: proj₁ proj₂ <_,_>

  sums:set : ∀{i} -> Sums (cat:set {i}) _⊎_
  sums:set = Sums: inj₁ inj₂ Data.Sum.[_,_]

  products:cat : ∀{i j} -> Products (cat:cat {i} {j}) cat×
  products:cat = Products: (homo proj₁) (homo proj₂)
                 λ where (homo f) (homo g) → homo ⟨ f , g ⟩


-- -- FIXME: These seem to be taking a while to compile. :(
-- module _ {i j} {{C : Cat i j}} {{Prod : Products C}} {{Exp : Exponentials C}} where
--   uncurry : ∀{a b c : Obj C} -> a ≤ b ⇨ c -> a ∧ b ≤ c
--   uncurry f = ×-map f id • apply
--   -- uncurry f = cov ×-homo (f , id) • apply

--   flip : ∀{a b c} -> a ≤ b ⇨ c -> b ≤ a ⇨ c
--   flip f = curry (swap • uncurry f)


-- -- Just a convenience for defining products, sums, and exponentials together.
-- record BiCC {i j} (C : Cat i j) : Set (i ⊔ j) where
--   field instance pros : Products C
--   field instance sums : Sums C
--   field instance exps : Exponentials C {{pros}}

-- -- Sets is bicartesian closed. Cat is, too, but since our Cats are lawless we're
-- -- ignoring naturality, so we only define products and sums.
-- instance
--   -- I'm not sure this is working!
--   bicc:set : ∀{i} -> BiCC (cat:set {i})
--   BiCC.pros bicc:set = record { _∧_ = _×_ ; π₁ = proj₁ ; π₂ = proj₂ ; ⟨_,_⟩ = <_,_> }
--   BiCC.sums bicc:set = record { _∨_ = _⊎_ ; in₁ = inj₁ ; in₂ = inj₂ ; [_,_] = Data.Sum.[_,_] }
--   _⇨_ {{BiCC.exps bicc:set}} = Function
--   apply {{BiCC.exps bicc:set}} (f , a) = f a
--   curry {{BiCC.exps bicc:set}} f a b = f (a , b)

--   products:cat : ∀{i j} -> Products (cat:cat {i}{j})
--   products:cat = record { _∧_ = cat× ; π₁ = homo π₁ ; π₂ = homo π₂
--     ; ⟨_,_⟩ = λ where (homo f) (homo g) → homo ⟨ f , g ⟩ }

--   sums:cat : ∀{i j} -> Sums (cat:cat {i}{j})
--   _∨_ {{sums:cat}} = cat+; in₁ {{sums:cat}} = homo rel₁; in₂ {{sums:cat}} = homo rel₂
--   app ([_,_] {{sums:cat}} F G) = [ app F , app G ]
--   cov ([_,_] {{sums:cat}} F G) (rel₁ x) = cov F x
--   cov ([_,_] {{sums:cat}} F G) (rel₂ x) = cov G x
