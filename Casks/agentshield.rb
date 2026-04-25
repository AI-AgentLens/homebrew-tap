cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.720"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.720/agentshield_0.2.720_darwin_amd64.tar.gz"
      sha256 "3b0b67f02eb362e612cd1798034897a65a8884dcd1ae5656ca766b88263de067"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.720/agentshield_0.2.720_darwin_arm64.tar.gz"
      sha256 "243cd5639c60e92ace20dfd1726a8874143b55b76435138a29ec870485f6e47e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.720/agentshield_0.2.720_linux_amd64.tar.gz"
      sha256 "63b2d8ffe9a061add6a5e23f247365accab588b6700ee35bbcf9972d5de5b8e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.720/agentshield_0.2.720_linux_arm64.tar.gz"
      sha256 "2fc3d6b3b79ddcd926e8139adf95791f62625860a5a2ddf2ed2af372f45677a3"
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
