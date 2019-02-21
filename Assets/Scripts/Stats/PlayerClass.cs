﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using CCC.Abilities;

[RequireComponent(typeof(ControlStatBlock))]
public class PlayerClass : MonoBehaviour
{
    [HideInInspector]
    public List<PerkPrototype> allPerks;
    [HideInInspector]
    public List<PerkPrototype> takenPerks;
    public AbilitySet abilities;
    public AbilitySlotDictionary abilDict;
    private ControlStatBlock stats;

    public static bool CheckPrereq(PerkPrototype p, List<PerkPrototype> taken)
    {
        int matched = 0;
        foreach (PerkPrototype t in taken)
        {
            if (p.BlockedBy.Contains(t))
            {
                return false;
            }
            if (p.Require.Contains(t))
            {
                ++matched;
            }
        }
        if (p.RequireAll)
        {
            return matched >= p.Require.Count;
        }
        else
        {
            int req = p.Require.Count > 0 ? 1 : 0;
            return matched >= req;
        }
    }

    public static void AddAbilityToParent(GameObject o, string typeString)
    {
        System.Type type = System.Type.GetType(typeString);
        Component fv = o.AddComponent(type);
    }

    // Start is called before the first frame update
    void Start()
    {
        takenPerks = new List<PerkPrototype>();
        stats = GetComponent<ControlStatBlock>();
    }

    public bool TakePerk(PerkPrototype p)
    {
        if(CheckPrereq(p, takenPerks))
        {
            takenPerks.Add(p);
            stats.StatsChanged();
            foreach (AbilityPrototype a in p.grants)
            {
                Ability instA = a.Instance;
                abilities.Set.Add(instA);
                Debug.Log("Abil set len: "+abilities.Set.Count);
                //TODO: repalce with ui thing
                if (abilDict.GetAbility(AbilitySlot.One).Equals(Ability.nullAbility))
                {
                    abilDict.SetSlotAbility(AbilitySlot.One, instA);
                    AddAbilityToParent(gameObject, instA.TypeString);
                } else if (abilDict.GetAbility(AbilitySlot.Two).Equals(Ability.nullAbility))
                {
                    abilDict.SetSlotAbility(AbilitySlot.Two, instA);
                    AddAbilityToParent(gameObject, instA.TypeString);
                } else if(abilDict.GetAbility(AbilitySlot.Three).Equals(Ability.nullAbility))
                {
                    abilDict.SetSlotAbility(AbilitySlot.Three, instA);
                    AddAbilityToParent(gameObject, instA.TypeString);
                } else if (abilDict.GetAbility(AbilitySlot.Four).Equals(Ability.nullAbility))
                {
                    abilDict.SetSlotAbility(AbilitySlot.Four, instA);
                    AddAbilityToParent(gameObject, instA.TypeString);
                } else if(abilDict.GetAbility(AbilitySlot.Five).Equals(Ability.nullAbility))
                {
                    abilDict.SetSlotAbility(AbilitySlot.Five, instA);
                    AddAbilityToParent(gameObject, instA.TypeString);
                }
            }
            return true;
        } else
        {
            return false;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
