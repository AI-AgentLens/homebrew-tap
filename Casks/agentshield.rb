cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.245"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.245/agentshield_0.2.245_darwin_amd64.tar.gz"
      sha256 "bc2203880212fe057497e3de2592605f2835892257080fd17e92a03d58b7c3f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.245/agentshield_0.2.245_darwin_arm64.tar.gz"
      sha256 "c092fb5e31978f2ba045962aff81d2a7ce3acc2b0df954b36d54c4a1dcdf9f5e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.245/agentshield_0.2.245_linux_amd64.tar.gz"
      sha256 "706f56b8363a32e0afa639ebccad7aaedd535fc121205152e946795e75b40d6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.245/agentshield_0.2.245_linux_arm64.tar.gz"
      sha256 "b7456e35d89dac70a0046231436574d59f8d815a0494d94ead053bc240ac048b"
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
