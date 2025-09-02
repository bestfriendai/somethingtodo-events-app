# CodeRabbit Review Request

## 📋 Review Scope

Please conduct a comprehensive review of the entire SomethingToDo Flutter application codebase.

### Key Areas for Review

#### 1. **Code Quality**
- Flutter best practices
- Dart conventions
- Code organization and structure
- DRY principle adherence
- SOLID principles

#### 2. **Performance**
- Widget rebuilding optimization
- Memory leaks
- Async operation handling
- Image caching strategies
- Animation performance

#### 3. **Security**
- API key handling
- Authentication flows
- Data validation
- Firebase security rules
- Input sanitization

#### 4. **Architecture**
- State management (Provider)
- Service layer design
- Repository pattern implementation
- Error handling strategies
- Dependency injection

#### 5. **Testing**
- Test coverage gaps
- E2E test completeness
- Unit test quality
- Widget test coverage

#### 6. **UI/UX**
- Accessibility compliance
- Responsive design
- Platform-specific adaptations
- Error states handling
- Loading states

#### 7. **Firebase Integration**
- Firestore query optimization
- Security rules effectiveness
- Cloud Functions efficiency
- Analytics implementation

#### 8. **Third-party Services**
- RapidAPI integration
- Stripe payment handling
- Google Maps implementation
- Push notifications

### Recent Changes Requiring Special Attention

1. **Performance Optimizations**
   - ModernSkeleton widget fixes
   - FPS improvements (1 → 60+ FPS)
   - Animation optimizations

2. **UI Improvements**
   - Header gradient fixes
   - Category filter functionality
   - Bottom navigation overflow fixes

3. **Production Readiness**
   - Error handling service
   - E2E test suite
   - Build configurations

### Expected Deliverables

- [ ] Security vulnerability report
- [ ] Performance bottleneck analysis
- [ ] Code smell identification
- [ ] Best practice violations
- [ ] Refactoring suggestions
- [ ] Test coverage improvements
- [ ] Documentation gaps

### Priority Issues

Please prioritize:
1. **Critical**: Security vulnerabilities
2. **High**: Performance issues affecting UX
3. **Medium**: Code quality and maintainability
4. **Low**: Style and convention violations

## 📊 Codebase Statistics

- **Language**: Flutter/Dart
- **Platform**: iOS, Android, Web
- **State Management**: Provider
- **Backend**: Firebase
- **APIs**: RapidAPI for events
- **Payment**: Stripe
- **Lines of Code**: ~30,000+
- **Test Coverage**: E2E tests included

## 🎯 Success Criteria

The review should:
1. Identify all critical security issues
2. Find performance optimization opportunities
3. Suggest architectural improvements
4. Highlight testing gaps
5. Recommend best practices

---

*This review request is for the entire codebase of the SomethingToDo events application.*