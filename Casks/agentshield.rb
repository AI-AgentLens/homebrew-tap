cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1879"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1879/agentshield_0.2.1879_darwin_amd64.tar.gz"
      sha256 "ac501a400d8d030d26a52dd85fa731378b781d95db761f178e55bebdb4b2ca44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1879/agentshield_0.2.1879_darwin_arm64.tar.gz"
      sha256 "12545327b0c6792e3fd9e9fe5fc8b5f1f9bc4325350ba96247152947295cfd82"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1879/agentshield_0.2.1879_linux_amd64.tar.gz"
      sha256 "cd596d54faa2e6ff94385ebb7c9928339f93617c801c07850e5137291b428c10"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1879/agentshield_0.2.1879_linux_arm64.tar.gz"
      sha256 "ce3b4dd7a6218f8443119a210eb15b37e1828887a1d8509753af107908dadcc3"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
