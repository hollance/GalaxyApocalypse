
#import "Box2D.h"
#import <vector>

struct Contact
{
	b2Fixture *fixtureA;
	b2Fixture *fixtureB;

	bool operator == (const Contact &other) const
	{
		return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
	}
};

typedef std::vector<Contact> ContactList;
typedef ContactList::iterator ContactIterator;

class ContactListener : public b2ContactListener
{
public:
	ContactList contacts;

	ContactListener();
	virtual ~ContactListener();

	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);
	virtual void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse);
};
