import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/core/services/ticket_service.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/features/events/models/ticket_model.dart';

class AvailableTicketsList extends StatefulWidget {
  final String eventId;
  final Set<String> loadingTickets;
  final Function(TicketType) onPurchase;

  const AvailableTicketsList({
    super.key,
    required this.eventId,
    required this.loadingTickets,
    required this.onPurchase,
  });

  @override
  State<AvailableTicketsList> createState() => _AvailableTicketsListState();
}

class _AvailableTicketsListState extends State<AvailableTicketsList> {
  List<TicketType> _ticketTypes = [];
  bool _isLoading = true;
  String _error = '';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    print("🎫 AvailableTicketsList initialized for event: ${widget.eventId}");
    _loadTicketTypes();
  }

  Future<void> _loadTicketTypes() async {
    try {
      if (!_isRefreshing) {
        setState(() {
          _isLoading = true;
          _error = '';
        });
      }

      
      final result = await TicketService.getAvailableTickets(widget.eventId); 
      
    
      
      setState(() {
        _ticketTypes = result;
        _isLoading = false;
        _isRefreshing = false;
      });
      
      
    } catch (e) {
     
      setState(() {
        _error = 'Failed to load tickets: ${e.toString()}';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refresh() async {
   
    setState(() {
      _isRefreshing = true;
    });
    await _loadTicketTypes();
  }

  @override
  Widget build(BuildContext context) {
   

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    if (_ticketTypes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _ticketTypes.length,
        itemBuilder: (context, index) {
          final ticketType = _ticketTypes[index];
          final isLoading = widget.loadingTickets.contains(ticketType.id);
          final availableQuantity = ticketType.totalQuantity - ticketType.soldQuantity;

         

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticketType.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  if (ticketType.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ticketType.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price: \$${ticketType.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Available: $availableQuantity',
                        style: TextStyle(
                          color: availableQuantity > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: availableQuantity > 0 && !isLoading
                          ? () => widget.onPurchase(ticketType)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: availableQuantity > 0 
                            ? AppTheme.primaryColor 
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              availableQuantity > 0 
                                  ? 'Purchase Ticket' 
                                  : 'Sold Out',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
   
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load tickets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTicketTypes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
  
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Tickets Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no tickets available for this event at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}