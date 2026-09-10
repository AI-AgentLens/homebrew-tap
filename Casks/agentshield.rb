cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2106"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2106/agentshield_0.2.2106_darwin_amd64.tar.gz"
      sha256 "d58dac7bf1ef664481495a2b9c9c2dd088e41bc4054ab8e49d81ba7868bc4bfa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2106/agentshield_0.2.2106_darwin_arm64.tar.gz"
      sha256 "066b09c6f351e11597a1100b059c7fce72a51973f55e07c25d8dce0ab99001ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2106/agentshield_0.2.2106_linux_amd64.tar.gz"
      sha256 "4d7dc2f94ae2006fce939ce1acc7e2d8fc7e7d01dcc864aa41b62c89f5cb3497"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2106/agentshield_0.2.2106_linux_arm64.tar.gz"
      sha256 "aa637e2223483f7100e2f1c0f075500d4f8abeaac039de3e1deee2f7057dd68d"
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
