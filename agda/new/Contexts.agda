module Contexts (Type : Set) where

open import Prelude

---------- Contexts ----------
Cx : Set1
Cx = Type -> Set

∅ : Cx
∅ _ = ⊥

hyp : Type -> Cx
hyp = _≡_

infixr 4 _∪_
_∪_ : Cx -> Cx -> Cx
(X ∪ Y) a = X a ⊎ Y a

infixr 4 _∷_
_∷_ : Type -> Cx -> Cx
a ∷ X = hyp a ∪ X

pattern here = inj₁ Eq.refl
pattern next x = inj₂ x


---------- Context renamings ----------
infix 1 _⊆_
_⊆_ : Cx -> Cx -> Set
X ⊆ Y = ∀ a -> X a -> Y a

instance
  cxs : Cat _ _
  cxs .Obj = Cx
  cxs .Hom = _⊆_
  cxs .ident _ = id
  cxs .compo X⊆Y Y⊆Z x = X⊆Y x • Y⊆Z x

-- ∪ forms coproducts on Cx under renaming.
instance
  cx-sums : Sums _ _
  Sums.cat cx-sums = cxs
  _∨_ {{cx-sums}} = _∪_
  in₁ {{cx-sums}} _ = inj₁
  in₂ {{cx-sums}} _ = inj₂
  [_,_] {{cx-sums}} f g _ = [ f _ , g _ ]

∪/⊆ : ∀ {X L R} -> L ⊆ R -> X ∪ L ⊆ X ∪ R
∪/⊆ f = [ in₁ , f • in₂ ]

∷/⊆ : ∀ L {R a} -> L ⊆ R -> a ∷ L ⊆ a ∷ R
∷/⊆ _ = ∪/⊆
