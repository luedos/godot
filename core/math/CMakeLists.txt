
# In the scons version here all we doing is cloning global environment.
# This can be a sign that future modules can expand environment in a way that this spesific module does't like.
# Or It can be a sign that someone just like cloning stuff..
# I will think that this is the second case, but just if math sources will break for unexplicable reasons, 
# I will left this comment here to help me in the future.
target_glob_sources(core-math-lib PRIVATE "*.cpp")