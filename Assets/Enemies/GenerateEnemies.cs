﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GenerateEnemies : MonoBehaviour
{
    private float spawnRange;

    private int enemiesNumber;
    private GameObject[] enemies;

    public EnemiesList enemiesTypes;

    public void Start()
    {
        spawnRange = 10f;
        
        // Random number of enemies
        // enemiesNumber = Random.Range(1, 3);
        enemiesNumber = 1;
        enemies = new GameObject[enemiesNumber];
        
        for (int i = 0; i < enemiesNumber; i++)
        {
            int type = Random.Range(0, enemiesTypes.enemeisList.Count - 1);
            enemies[i] = Instantiate(enemiesTypes.enemeisList[type], transform.position, Quaternion.identity, transform);
            enemies[i].name = "Enemy - " + enemiesTypes.enemeisList[type].name;
        }
    }

    private Vector3 RandomPos()
    {
        Vector2 randomPoint = Random.insideUnitCircle * spawnRange;
        return transform.position + new Vector3(randomPoint.x, 1.0f, randomPoint.y);
    }
}
