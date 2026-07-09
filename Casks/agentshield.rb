cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1589"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1589/agentshield_0.2.1589_darwin_amd64.tar.gz"
      sha256 "892fdb7d7f4f6fe6a2ec62ad4d1f9f20f063527c3193c6c45d6914e49a2a3d4d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1589/agentshield_0.2.1589_darwin_arm64.tar.gz"
      sha256 "bd18db30ff6abf7c740c017795d684711cd1f9a0296da08b60dd2fdd0e9f4bd9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1589/agentshield_0.2.1589_linux_amd64.tar.gz"
      sha256 "a98abdb189fe71199d28f48f1b1076feb4932c12c8f8dd4dde5afa1d40fce736"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1589/agentshield_0.2.1589_linux_arm64.tar.gz"
      sha256 "d6451ef71bd2962b408403d9004f117d9cc25f82949079683fc9d99e849841cd"
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
