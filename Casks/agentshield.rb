cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.547"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.547/agentshield_0.2.547_darwin_amd64.tar.gz"
      sha256 "abec522c262c2348be88dd77db5418c70bb80fe47a9f5325c2db503d37b13c2e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.547/agentshield_0.2.547_darwin_arm64.tar.gz"
      sha256 "4500d49ecc534fe94b67e24c7d2dadf94d23eb4a23d72ec3fab0216eb0ebf247"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.547/agentshield_0.2.547_linux_amd64.tar.gz"
      sha256 "8a1845e3e4cab3d34aa75f44661389697af3e24028680d5460fe7c1459a46fe0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.547/agentshield_0.2.547_linux_arm64.tar.gz"
      sha256 "3d0ce7d2d9f8f9bc1da84dd123958462d34ef34be3218f5f5ada834f29529c3a"
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
