cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2261"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2261/agentshield_0.2.2261_darwin_amd64.tar.gz"
      sha256 "e2be1885205fb7d44dd68ce992f1ec1be8894fe904194ec767b99aa98677f55f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2261/agentshield_0.2.2261_darwin_arm64.tar.gz"
      sha256 "0a231b6915490b601366876cc2116bb9b57d4b84cbdd2556a17aeb92ff2401b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2261/agentshield_0.2.2261_linux_amd64.tar.gz"
      sha256 "b3bc1c98d6b7f1473ac3b6b647d33a0abb017613a4e06ee917e4041a874f8a23"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2261/agentshield_0.2.2261_linux_arm64.tar.gz"
      sha256 "664e9722c11843f230f524d1e5c8e2b098b2164e40c81e775976c8d8499f089f"
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
