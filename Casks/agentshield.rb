cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.117"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.117/agentshield_0.2.117_darwin_amd64.tar.gz"
      sha256 "69287f9cad66a143e56fafcc04bd67e6827ad79b23b28ddef4dbbe70db3b5299"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.117/agentshield_0.2.117_darwin_arm64.tar.gz"
      sha256 "d31af29423423e0db046c4edec2bf54346125f13dbb72beee975818fbcc9c330"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.117/agentshield_0.2.117_linux_amd64.tar.gz"
      sha256 "25d96812d658693a02b8af7ee057140507c243026984b0bc9435af33b3f380b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.117/agentshield_0.2.117_linux_arm64.tar.gz"
      sha256 "55608a00b5ebdb738a6f5b917a6cb48521177c3f2c4f4c693bd657c91f0a55b9"
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
