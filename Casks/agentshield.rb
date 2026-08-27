cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1966"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1966/agentshield_0.2.1966_darwin_amd64.tar.gz"
      sha256 "dee524f92e14f0731232fa263f379b272c3b1404f5ec9ffb95fa86a715884233"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1966/agentshield_0.2.1966_darwin_arm64.tar.gz"
      sha256 "2181a6c89e9226f70630635a9f6ee207c1f1e03a5bda99db76ea4a292b62e944"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1966/agentshield_0.2.1966_linux_amd64.tar.gz"
      sha256 "83cf17d9b3d0e8a8dd681d4bc829e2a96122640e22144d483e55e5c9cea108aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1966/agentshield_0.2.1966_linux_arm64.tar.gz"
      sha256 "11bd321d7e7efb351f298ecc33dbe62a392a35b2ecc84d9e6fd30e7dc9cb86e4"
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
