import LeafProvider
import MySQLProvider

extension Config {
    public func setup() throws {
        // Allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]
        try setupProviders()
    }
    
    /// Configures providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        
        // Run migrations aka preparations
        preparations.append(Activity.self)
        preparations.append(User.self)
        preparations.append(Course.self)
        preparations.append(Class.self)
        preparations.append(Pivot<User, Class>.self)
        preparations.append(Clue.self)
        preparations.append(Choice.self)
        preparations.append(Treasure.self)
        preparations.append(Game.self)
        preparations.append(Pivot<Clue, Game>.self)
        preparations.append(GameDeployment.self)
        preparations.append(Sidekick.self)
        preparations.append(GameResultClue.self)
        preparations.append(GameResultTreasure.self)
    }
}
