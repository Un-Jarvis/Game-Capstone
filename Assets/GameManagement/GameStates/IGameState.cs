﻿using UnityEngine.Events;

namespace CCC.GameManagement.GameStates
{
    /// <summary>
    /// Represents a state of a Game.
    /// </summary>
    public interface IGameState
    {
        UnityAction<Game> OnEnter { get; }
        UnityAction<Game> OnExit { get; }
        SceneReference SceneReference { get; }

        /// <summary>
        /// Have the given Game enter this IGameState.
        /// </summary>
        /// <param name="game">The Game to enter this IGameState.</param>
        //void Enter(Game game);

        /// <summary>
        /// Have the given Game exit this IGameState.
        /// </summary>
        /// <param name="game">The Game to exit this IGameState.</param>
        //void Exit(Game game);
    }
}