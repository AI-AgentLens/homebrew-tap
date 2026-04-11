cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.540"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.540/agentshield_0.2.540_darwin_amd64.tar.gz"
      sha256 "bc72588ed06a950922ff2d099637178e482f4dc9606245ad7db4695d09ecf6f0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.540/agentshield_0.2.540_darwin_arm64.tar.gz"
      sha256 "461a668e278681f68e05d8accf582d51f4c9ccc53346b05c67165b7abe72dc02"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.540/agentshield_0.2.540_linux_amd64.tar.gz"
      sha256 "896411861865a4b51147416fc77e892fe4d12d49aaa1cd9f6089cfb76a6ac945"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.540/agentshield_0.2.540_linux_arm64.tar.gz"
      sha256 "3491e5b0c027ae9cda0f71404bf6401375455adba8b4d7465d1713902b893ed5"
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
