cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.438"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.438/agentshield_0.2.438_darwin_amd64.tar.gz"
      sha256 "2e778361d875f4f613373e3b69f1e5038bbbb946038043ec2a56486394eba782"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.438/agentshield_0.2.438_darwin_arm64.tar.gz"
      sha256 "5c8d86b56e40ebf1dd3c0643160e5fb645feae0201f473db6cdb9ae9567ce4e4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.438/agentshield_0.2.438_linux_amd64.tar.gz"
      sha256 "e9a73bc2dd21c9c7c38ae0d30c7c1021837e72226cd18cd856f389790c97a612"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.438/agentshield_0.2.438_linux_arm64.tar.gz"
      sha256 "db0ae264c753e3301f6021814eba1d15ddfce1f64d9f18bad1418bf7599cfd04"
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
