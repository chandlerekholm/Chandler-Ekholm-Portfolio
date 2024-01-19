using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ekholm_Classes
{
    class texasHoldEm
    {
        public static void Main(string[] args)
        { 
            Console.WriteLine("Welcome to the super alpha build program");
            var gameChat = new Chat();
            var gameDeck = new Deck();
            gameDeck.isShuffled = true; //The program shuffles a deck of 52 cards when a new game starts,
            gameDeck.cardCount = 52;
            Console.WriteLine("Let's make 4 players");
            var Dempsey = new Player();
            Dempsey.Name = "Dempsey";
            gameDeck.cardCount = gameDeck.cardCount - 2;
            Dempsey.cardsInHand = 2;
            Dempsey.canSeeCards = false;
            var Nikolai = new Player();
            Nikolai.Name = "Nikolai";
            gameDeck.cardCount = gameDeck.cardCount - 2;
            Nikolai.cardsInHand = 2;
            Nikolai.canSeeCards = false;
            var Takeo = new Player();
            Takeo.Name = "Takeo";
            Takeo.cardsInHand = 2;
            Takeo.canSeeCards = false;
            gameDeck.cardCount = gameDeck.cardCount - 2;
            var Richtofen = new Player();
            Richtofen.Name = "Richtofen";
            gameDeck.cardCount = gameDeck.cardCount - 2;
            Richtofen.cardsInHand = 2;
            Richtofen.canSeeCards = false;

            Console.WriteLine(String.Format("Players {0},{1},{2},{3},\nhave {4},{5},{6},{7} cards, respectively", Dempsey.Name, Nikolai.Name, Takeo.Name, Richtofen.Name, Dempsey.cardsInHand, Nikolai.cardsInHand, Takeo.cardsInHand, Richtofen.cardsInHand));
            Console.WriteLine(String.Format("The deck currently has {0} cards in it", gameDeck.cardCount));

            Console.WriteLine(String.Format("Let's let everyone see their cards now"));
            Dempsey.canSeeCards = true;
            Nikolai.canSeeCards = true;
            Takeo.canSeeCards = true;
            Richtofen.canSeeCards = true;

            gameChat.printChat(Dempsey, "Let's start this up. Ooorah");
            gameChat.printChat(Nikolai, "You all don't stand a chance");



        }
    }
}
