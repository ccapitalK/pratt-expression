mixin template AutoHashEquals() {
    override bool opEquals(Object o) const {
        if (auto other = cast(typeof(this))o) {
            foreach (member; FieldNameTuple!(typeof(this))) {
                if (mixin("this." ~ member) != mixin("other." ~ member)) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    override size_t toHash() const @safe nothrow {
        size_t hash = 0;
        foreach (member; FieldNameTuple!(typeof(this))) {
            hash ^= typeid(typeof(mixin("this." ~ member))).getHash(&mixin("this." ~ member));
            hash *= 16_777_619;
        }
        return hash;
    }
}
