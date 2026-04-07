cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.455"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.455/agentshield_0.2.455_darwin_amd64.tar.gz"
      sha256 "02a00de360a33b848777159e904981c3f336f8b9ffff7449c2553e426d5e9881"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.455/agentshield_0.2.455_darwin_arm64.tar.gz"
      sha256 "1e2d3eda06c4668d7b4f3e845051dd45e857dcb8f57593d6b433465ebaf6c973"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.455/agentshield_0.2.455_linux_amd64.tar.gz"
      sha256 "e9d06822cdcce4177addceed7e941f36bcb80ffd3f55d46c9a738fa5c0abfccf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.455/agentshield_0.2.455_linux_arm64.tar.gz"
      sha256 "a89fc883469f1540da55c0f989e568d6e27c4a46e73584b8f0a15a2f2b368865"
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
