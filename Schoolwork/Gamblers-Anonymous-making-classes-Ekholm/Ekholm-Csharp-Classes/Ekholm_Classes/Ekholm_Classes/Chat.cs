using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ekholm_Classes
{
    public class Chat
    {
        //Players can send and receive messages without disrupting gameplay.
        //Messaging would be local to all players in the game and
        //private messaging to players within the game would not be allowed. 



        public void printChat(Player player, String message)
        {
            Console.WriteLine(String.Format("{0}: {1}", player.Name, message));
        }

    }
}
