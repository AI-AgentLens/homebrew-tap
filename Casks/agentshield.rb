cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.760"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.760/agentshield_0.2.760_darwin_amd64.tar.gz"
      sha256 "203f13b5a7bfaaa4dcc1fda7a8921afff4085476f324e083e01f7096c0aac2b7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.760/agentshield_0.2.760_darwin_arm64.tar.gz"
      sha256 "6dfda159624939e559f1974ac03c234653a3f47d90a929293ba76e9fa62462b4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.760/agentshield_0.2.760_linux_amd64.tar.gz"
      sha256 "c33e5f2e48ce02a7ba91e0b5057eaad00307176210e195f6b400f3d474a5bcab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.760/agentshield_0.2.760_linux_arm64.tar.gz"
      sha256 "75949376f30a7089f06b83028e2038eb420031a12f3690136f7f1dc88dfcfd4e"
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
