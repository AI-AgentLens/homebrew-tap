cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2451"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2451/agentshield_0.2.2451_darwin_amd64.tar.gz"
      sha256 "15137d9f84ebf420fbbe4b71372e907cfbcaa3f175a073a15a62226b5a5b2248"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2451/agentshield_0.2.2451_darwin_arm64.tar.gz"
      sha256 "fe1a97e90a59c018bed77bbebdefde12f5f46567b425279373e8200f67c1a78e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2451/agentshield_0.2.2451_linux_amd64.tar.gz"
      sha256 "86cf64270666fbe49f84a80cb00eb15c046675f768f37d2fff487c234d5f3b7a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2451/agentshield_0.2.2451_linux_arm64.tar.gz"
      sha256 "b6a8b30eb0f317995e2a93653ef732c9032b2635889d07e0c26bb16722751f1c"
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
