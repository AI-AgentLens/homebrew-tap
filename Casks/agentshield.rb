cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.766"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.766/agentshield_0.2.766_darwin_amd64.tar.gz"
      sha256 "880793bf2ca3eef53157207de82aa98d038f959378490a84eb3934f6b1ac1fac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.766/agentshield_0.2.766_darwin_arm64.tar.gz"
      sha256 "f8ed4b67925effb6d6d8045ca0f07ec7951cd227e3d1b4c9c1ae64b56b549116"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.766/agentshield_0.2.766_linux_amd64.tar.gz"
      sha256 "703dac5cb5964f852b3d426fb86713e9827b460ae69fe5942ba3deb5017233c2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.766/agentshield_0.2.766_linux_arm64.tar.gz"
      sha256 "ff96dfa610e846f64cee155b8c3615faf5a76b4eb45fa99eeda29d48ecd5444c"
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
