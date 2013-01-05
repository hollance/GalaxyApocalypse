
#import "ContactListener.h"
#import <algorithm>

ContactListener::ContactListener() : contacts()
{
	// do nothing
}

ContactListener::~ContactListener()
{
	// do nothing
}

void ContactListener::BeginContact(b2Contact *contact)
{
	Contact c = { contact->GetFixtureA(), contact->GetFixtureB() };
	contacts.push_back(c);
}

void ContactListener::EndContact(b2Contact *contact)
{
	Contact c = { contact->GetFixtureA(), contact->GetFixtureB() };
	ContactIterator pos = std::find(contacts.begin(), contacts.end(), c);
	if (pos != contacts.end())
		contacts.erase(pos);
}

void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold)
{
	// do nothing
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse)
{
	// do nothing
}
