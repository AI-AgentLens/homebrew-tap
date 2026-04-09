cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.512"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.512/agentshield_0.2.512_darwin_amd64.tar.gz"
      sha256 "03bc80283bcaba6a1a5489440f4e60cda8541de3724a8e2f0f1570b314abf01a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.512/agentshield_0.2.512_darwin_arm64.tar.gz"
      sha256 "7a5d8fba2f2475a4884a817bcc714621adc44a6762b7c64f0d7d666f4e885029"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.512/agentshield_0.2.512_linux_amd64.tar.gz"
      sha256 "8089d482d4ca2d3798b93d940016c95cded084fcb5deafb26d7d5f84a0845a43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.512/agentshield_0.2.512_linux_arm64.tar.gz"
      sha256 "2bbca5cd0d3de5c22824912d27856e26e392072414bc244dca476da06a04f5a9"
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
