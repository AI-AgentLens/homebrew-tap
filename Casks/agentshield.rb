cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1525"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1525/agentshield_0.2.1525_darwin_amd64.tar.gz"
      sha256 "ad029b3e85c94ec73d5a3f56ac90c38cf5a0bb238add8f7999c1bde4a8bac11e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1525/agentshield_0.2.1525_darwin_arm64.tar.gz"
      sha256 "6b006a6124a563471cd0e329493bbb892d2a28ab467f238954b504c619fde267"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1525/agentshield_0.2.1525_linux_amd64.tar.gz"
      sha256 "11d9f8754ba30ae39984e4fb36e883b050a04faeb609ce5efaa33323832cda4c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1525/agentshield_0.2.1525_linux_arm64.tar.gz"
      sha256 "a5c073223a24cbd457e2056ab0f415f917e5fdaa98a2621959f7d7929ab58988"
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
