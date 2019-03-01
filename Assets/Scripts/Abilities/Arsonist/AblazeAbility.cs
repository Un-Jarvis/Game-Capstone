﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using CCC.Stats;

[RequireComponent(typeof(StatBlock))]
[RequireComponent(typeof(PlayerClass))]
[RequireComponent(typeof(MousePositionDetector))]
public class AblazeAbility : AbilityBase
{
    private readonly string AbilName = "Ablaze";

    private List<Stat> abilStats;
    private StatBlock stats;
    private MousePositionDetector mpd;
    private GameObject aoeObj;

    private float duration;
    private float size;
    private float igniteMult;
    private bool buffs;
    private bool debuffs;

    public static TimedBuffPrototype Friendly;
    public static TimedBuffPrototype Enemy;
    public static TimedBuffPrototype Ignite;

    public override void UpdateStats()
    {
        cdBase = abilStats.Find(item => item.Name == Stat.AS_CD).Value;
        duration = abilStats.Find(item => item.Name == Stat.AS_DUR).Value;
        size = abilStats.Find(item => item.Name == Stat.AS_SIZE).Value;
        buffs = abilStats.Find(item => item.Name == Stat.AS_BUFFS).Value > 1f;
        debuffs = abilStats.Find(item => item.Name == Stat.AS_DEBUFFS).Value > 1f;
        igniteMult = abilStats.Find(item => item.Name == Stat.AS_IGNITE_MULT).Value;
    }

    protected override void Activate()
    {
        GameObject obj = Instantiate(aoeObj, mpd.CalculateWorldPosition(), new Quaternion());
        obj.transform.localScale = new Vector3(size, 1f, size);
        AoeBehave ab = obj.GetComponent<AoeBehave>();
        ab.friendly = true;
        ab.ttl = duration;
        ab.Friend = new List<TimedBuff>();
        ab.Enemy = new List<TimedBuff>();
        TimedBuff ignite = Ignite.Instance;
        ignite.Stats.Clear();
        ignite.Stats.Add(new Stat(Stat.HEALTH_REGEN, StatBlock.CalcMult(-15, igniteMult)));
        ab.Enemy.Add(ignite);
        if (buffs)
        {
            Debug.Log("Buffs");
            ab.Friend.Add(Friendly.Instance);
        }
        if(debuffs)
            ab.Enemy.Add(Enemy.Instance);
    }

    // Start is called before the first frame update
    void Start()
    {
        stats = GetComponent<StatBlock>();
        mpd = GetComponent<MousePositionDetector>();
        PlayerClass pc = GetComponent<PlayerClass>();

        abil = pc.abilities.Set[AbilName];
        abilStats = abil.Stats;
        aoeObj = abil.Prefab;
        abil.cdRemain = 0f;
        UpdateStats();
    }
    
}
