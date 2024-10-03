import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatefulWidget {
  final int notificationCount;
  final int notificationCountCovoiturage;
  final ValueChanged<int> onChange;

  const CustomBottomAppBar({
    super.key,
    required this.notificationCount,
    required this.onChange,
    required this.notificationCountCovoiturage,
  });

  @override
  _CustomBottomAppBarState createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
      widget.onChange(index);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white54,
          ),
        ),
      ),
      child: BottomAppBar(
        height: 70,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomAppBarItem(Icons.home, 'Accueil', 0),
            _buildNotificationItemCovoiturage(Icons.car_crash, 'Covoiturage', 1),
            _buildBottomAppBarItem(Icons.add_box, 'Publier', 2),
            _buildNotificationItem(Icons.notifications, 'Notifications', 3),
            _buildBottomAppBarItem(Icons.person, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBarItem(IconData icon, String title, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.blue : Colors.grey[500],
          ),
          Text(
            title,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.blue : Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, String title, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 22),
                child: Icon(
                  icon,
                  color: _selectedIndex == index ? Colors.blue : Colors.grey[500],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: Text(
                  title,
                  style: TextStyle(
                    color: _selectedIndex == index ? Colors.blue : Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ),
              if (widget.notificationCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 40),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    maxWidth: 16,
                    maxHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.notificationCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
  Widget _buildNotificationItemCovoiturage(IconData icon, String title, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 22),
                child: Icon(
                  icon,
                  color: _selectedIndex == index ? Colors.blue : Colors.grey[500],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: Text(
                  title,
                  style: TextStyle(
                    color: _selectedIndex == index ? Colors.blue : Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ),
              if (widget.notificationCountCovoiturage > 0)
                Positioned(
                  bottom: 28,
                  child: Container(
                    margin: const EdgeInsets.only(left: 35),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 14,
                      maxHeight: 14,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.notificationCountCovoiturage}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}
/* if (widget.notificationCount > 0)
            Container(
              margin: EdgeInsets.only(left: 45),
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: BoxConstraints(
                maxWidth: 20,
                maxHeight: 20,
              ),
              child: Center(
                child: Text(
                  '${widget.notificationCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),*/